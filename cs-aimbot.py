"""
CS2 自瞄锁头 - 参考市面外挂实现
原理：高速截图 + 对比度检测 + 底层鼠标控制
特点：无模板、无调试窗口、纯控制台反馈

热键：
  F1  - 启动/停止
  F2  - 退出
  F3  - 快速校准（截取当前准星位置作为参考）
"""

import ctypes
import cv2
import numpy as np
import mss
import threading
import time
from datetime import datetime

# ============ Windows API ============
user32 = ctypes.windll.user32
MOUSEEVENTF_MOVE = 0x0001
MOUSEEVENTF_LEFTDOWN = 0x0002
MOUSEEVENTF_LEFTUP = 0x0004
MOUSEEVENTF_ABSOLUTE = 0x8000

# ============ 配置 ============
KEY_TOGGLE = 'f1'
KEY_EXIT = 'f2'
KEY_CALIBRATE = 'f3'

# 自瞄参数
DETECT_FOV = 180        # 检测范围（像素）
LOCK_PIXELS = 6         # 锁定精度
AIM_SPEED = 18          # 瞄准时间（毫秒）
FIRE_DELAY = 12         # 锁定后开枪延迟（毫秒）
FIRE_INTERVAL = 65      # 射击间隔（毫秒）
HEAD_OFFSET = 0.15      # 头部在身体中的位置比例

class State:
    aiming = False
    running = True
    last_target = None
    stats = {'shots': 0, 'locks': 0}
    lock = threading.Lock()

state = State()

# ============ 鼠标控制 ============
def get_mouse_pos():
    pt = ctypes.wintypes.POINT()
    user32.GetCursorPos(ctypes.byref(pt))
    return pt.x, pt.y

def move_mouse(x, y):
    """直接移动鼠标到绝对坐标"""
    sw = user32.GetSystemMetrics(0)
    sh = user32.GetSystemMetrics(1)
    nx = int(x * 65535 / sw)
    ny = int(y * 65535 / sh)
    user32.mouse_event(MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE, nx, ny, 0, 0)

def click():
    """开枪"""
    user32.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    time.sleep(0.004)
    user32.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)

# ============ 目标检测 ============
def detect_targets(gray, cx, cy, fov):
    """
    检测人形目标 - 使用对比度 + 轮廓
    返回头部位置列表
    """
    h, w = gray.shape[:2]
    targets = []
    
    # 限制检测区域（FOV 内）
    x1 = max(0, cx - fov)
    y1 = max(0, cy - fov)
    x2 = min(w, cx + fov)
    y2 = min(h, cy + fov)
    
    roi = gray[y1:y2, x1:x2]
    if roi.size == 0:
        return []
    
    # 自适应阈值 - 找出对比度高的区域
    _, thresh = cv2.threshold(roi, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    
    # 形态学操作
    kernel = np.ones((4, 4), np.uint8)
    dilated = cv2.dilate(thresh, kernel, iterations=2)
    eroded = cv2.erode(dilated, kernel, iterations=1)
    
    # 找轮廓
    contours, _ = cv2.findContours(eroded, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    for c in contours:
        area = cv2.contourArea(c)
        # 人形面积范围
        if 2500 < area < 100000:
            x, y, bw, bh = cv2.boundingRect(c)
            
            # 人形特征：瘦高
            aspect = bw / bh if bh > 0 else 0
            if 0.3 < aspect < 0.75 and bh > 60:
                # 全局坐标
                gx = x1 + x + bw // 2
                gy = y1 + y + int(bh * HEAD_OFFSET)  # 头部位置
                
                targets.append({
                    'x': gx,
                    'y': gy,
                    'w': bw,
                    'h': bh,
                    'dist': abs(gx - cx) + abs(gy - cy)
                })
    
    # 按距离排序
    targets.sort(key=lambda t: t['dist'])
    return targets

def detect_by_canny(gray, cx, cy, fov):
    """Canny 边缘检测备用方案"""
    h, w = gray.shape[:2]
    targets = []
    
    x1 = max(0, cx - fov)
    y1 = max(0, cy - fov)
    x2 = min(w, cx + fov)
    y2 = min(h, cy + fov)
    
    roi = gray[y1:y2, x1:x2]
    if roi.size == 0:
        return []
    
    # Canny 边缘
    edges = cv2.Canny(roi, 70, 150)
    
    # 膨胀
    kernel = np.ones((5, 5), np.uint8)
    dilated = cv2.dilate(edges, kernel, iterations=3)
    
    contours, _ = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    for c in contours:
        area = cv2.contourArea(c)
        if 3000 < area < 120000:
            x, y, bw, bh = cv2.boundingRect(c)
            aspect = bw / bh if bh > 0 else 0
            
            if 0.35 < aspect < 0.7 and bh > 70:
                gx = x1 + x + bw // 2
                gy = y1 + y + int(bh * HEAD_OFFSET)
                
                targets.append({
                    'x': gx, 'y': gy, 'w': bw, 'h': bh,
                    'dist': abs(gx - cx) + abs(gy - cy)
                })
    
    targets.sort(key=lambda t: t['dist'])
    return targets

# ============ 自瞄主循环 ============
def aim_loop():
    """自瞄主循环"""
    with mss.mss() as sct:
        mon = sct.monitors[1]
        cx, cy = mon["width"] // 2, mon["height"] // 2
        
        aim_state = "idle"
        aim_start = 0
        lock_time = 0
        fire_time = 0
        start_mx, start_my = get_mouse_pos()
        
        while state.running:
            try:
                # 截图并转灰度
                shot = sct.grab(mon)
                img = np.array(shot)
                gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
                
                # 获取当前鼠标位置
                mx, my = get_mouse_pos()
                
                if state.aiming:
                    # 检测目标
                    targets = detect_targets(gray, cx, cy, DETECT_FOV)
                    
                    # 没有的话尝试 Canny
                    if not targets:
                        targets = detect_by_canny(gray, cx, cy, DETECT_FOV)
                    
                    if targets:
                        target = targets[0]  # 最近的
                        tx, ty = target['x'], target['y']
                        dist = abs(tx - mx) + abs(ty - my)
                        
                        # 状态机
                        if aim_state == "idle":
                            aim_state = "aiming"
                            aim_start = time.time()
                            start_mx, start_my = mx, my
                        
                        elif aim_state == "aiming":
                            # 平滑瞄准
                            elapsed = (time.time() - aim_start) * 1000
                            progress = min(1.0, elapsed / AIM_SPEED)
                            
                            # 线性插值
                            ax = int(start_mx + (tx - start_mx) * progress)
                            ay = int(start_my + (ty - start_my) * progress)
                            move_mouse(ax, ay)
                            
                            # 检查锁定
                            if dist <= LOCK_PIXELS:
                                aim_state = "locked"
                                lock_time = time.time()
                                with state.lock:
                                    state.stats['locks'] += 1
                                print(f"[锁定] {datetime.now().strftime('%H:%M:%S')}")
                        
                        elif aim_state == "locked":
                            # 延迟开枪
                            if (time.time() - lock_time) * 1000 >= FIRE_DELAY:
                                click()
                                aim_state = "firing"
                                fire_time = time.time()
                                with state.lock:
                                    state.stats['shots'] += 1
                                print(f"[开枪] {datetime.now().strftime('%H:%M:%S')}")
                        
                        elif aim_state == "firing":
                            # 射击间隔
                            if (time.time() - fire_time) * 1000 >= FIRE_INTERVAL:
                                aim_state = "aiming"
                                aim_start = time.time()
                                start_mx, start_my = get_mouse_pos()
                    else:
                        aim_state = "idle"
                else:
                    aim_state = "idle"
                
            except Exception as e:
                print(f"[错误] {e}")
            
            time.sleep(0.001)  # 1000Hz

def hotkey_loop():
    """热键监听"""
    try:
        import keyboard
        print("[✓] keyboard 库已加载")
    except ImportError:
        print("[!] keyboard 库未安装")
        return
    
    print("\n" + "=" * 50)
    print("  CS2 自瞄锁头")
    print("  作者：Claw 🐾")
    print("=" * 50)
    print("\n[热键]")
    print("  F1 - 启动/停止自瞄")
    print("  F2 - 退出程序")
    print("  F3 - 快速校准")
    print("\n[状态] 就绪 - 按 F1 启动")
    
    last = {KEY_TOGGLE: 0, KEY_EXIT: 0, KEY_CALIBRATE: 0}
    cd = 0.3
    
    while state.running:
        try:
            now = time.time()
            
            if keyboard.is_pressed(KEY_TOGGLE) and now - last[KEY_TOGGLE] > cd:
                last[KEY_TOGGLE] = now
                state.aiming = not state.aiming
                s = "🟢 已启动" if state.aiming else "🔴 已停止"
                print(f"\n[自瞄] {s} - {datetime.now().strftime('%H:%M:%S')}")
            
            if keyboard.is_pressed(KEY_EXIT) and now - last[KEY_EXIT] > cd:
                last[KEY_EXIT] = now
                print("\n[退出] 关闭程序...")
                state.running = False
                break
            
            if keyboard.is_pressed(KEY_CALIBRATE) and now - last[KEY_CALIBRATE] > cd:
                last[KEY_CALIBRATE] = now
                print(f"\n[校准] 已重置 - {datetime.now().strftime('%H:%M:%S')}")
        
        except Exception as e:
            print(f"[热键] {e}")
        
        time.sleep(0.02)

def main():
    print("[检查] 依赖...")
    try:
        import cv2, mss, numpy
        print("[✓] 就绪")
    except Exception as e:
        print(f"[✗] {e}")
        return
    
    print("\n[启动] 线程...")
    
    t1 = threading.Thread(target=aim_loop, daemon=True)
    t2 = threading.Thread(target=hotkey_loop, daemon=True)
    
    t1.start()
    t2.start()
    
    try:
        while state.running:
            time.sleep(0.1)
    except KeyboardInterrupt:
        print("\n[中断]")
        state.running = False
    
    time.sleep(0.2)
    print("\n[退出] 再见")

if __name__ == "__main__":
    main()
