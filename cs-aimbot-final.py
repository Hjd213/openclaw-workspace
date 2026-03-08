"""
CS2 自瞄锁头 - 最终版
设计思路：
1. 使用 mss 截图（测试兼容性）
2. 简单的对比度检测（不依赖模板）
3. 测试鼠标控制是否有效
4. 控制台实时反馈

如果这个版本能检测到目标但鼠标不动，说明是鼠标控制的问题
如果检测不到目标，说明是截图或检测算法的问题

热键：
  F1 - 启动/停止
  F2 - 退出
  F3 - 测试鼠标移动
  F4 - 打印调试信息
"""

import ctypes
import cv2
import numpy as np
import mss
import threading
import time
from datetime import datetime

# ============ Win32 API ============
user32 = ctypes.windll.user32
MOUSEEVENTF_MOVE = 0x0001
MOUSEEVENTF_LEFTDOWN = 0x0002
MOUSEEVENTF_LEFTUP = 0x0004
MOUSEEVENTF_ABSOLUTE = 0x8000

# ============ 配置 ============
CFG = {
    'fov': 150,
    'lock_pixels': 8,
    'aim_time_ms': 20,
    'fire_delay_ms': 15,
    'fire_interval_ms': 70,
    'head_offset': 0.18,
}

class State:
    aiming = False
    running = True
    debug = False
    stats = {'shots': 0, 'locks': 0, 'detects': 0}
    lock = threading.Lock()

state = State()

# ============ 截图测试 ============
def test_screenshot():
    """测试截图是否成功"""
    print("\n[测试] 截图功能...")
    try:
        with mss.mss() as sct:
            mon = sct.monitors[1]
            print(f"  显示器：{mon['width']}x{mon['height']}")
            
            shot = sct.grab(mon)
            img = np.array(shot)
            print(f"  截图尺寸：{img.shape}")
            print(f"  截图类型：{type(img)}")
            
            # 保存测试截图
            cv2.imwrite('test_screenshot.png', img)
            print("  ✓ 截图已保存到 test_screenshot.png")
            
            # 显示中心区域颜色信息
            h, w = img.shape[:2]
            center = img[h//2-50:h//2+50, w//2-50:w//2+50]
            print(f"  中心区域平均亮度：{cv2.cvtColor(center, cv2.COLOR_RGB2GRAY).mean():.1f}")
            
            return True
    except Exception as e:
        print(f"  ✗ 截图失败：{e}")
        return False

# ============ 鼠标控制 ============
def get_mouse_pos():
    pt = ctypes.wintypes.POINT()
    user32.GetCursorPos(ctypes.byref(pt))
    return pt.x, pt.y

def move_mouse_pyautogui(x, y):
    """使用 pyautogui 移动鼠标"""
    try:
        import pyautogui
        pyautogui.moveTo(x, y, duration=0)
        return True
    except:
        return False

def move_mouse_win32(x, y):
    """使用 Win32 API 移动鼠标"""
    sw = user32.GetSystemMetrics(0)
    sh = user32.GetSystemMetrics(1)
    nx = int(x * 65535 / sw)
    ny = int(y * 65535 / sh)
    user32.mouse_event(MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE, nx, ny, 0, 0)
    return True

def click_mouse():
    """点击"""
    user32.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    time.sleep(0.003)
    user32.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)

def test_mouse_move():
    """测试鼠标移动"""
    print("\n[测试] 鼠标移动...")
    mx, my = get_mouse_pos()
    print(f"  当前鼠标位置：{mx}, {my}")
    
    # 测试移动
    target_x, target_y = mx + 100, my + 100
    print(f"  测试移动到：{target_x}, {target_y}")
    
    # 尝试 pyautogui
    if move_mouse_pyautogui(target_x, target_y):
        time.sleep(0.1)
        nx, ny = get_mouse_pos()
        print(f"  pyautogui 结果：{nx}, {ny}")
        if abs(nx - target_x) < 5 and abs(ny - target_y) < 5:
            print("  ✓ pyautogui 有效")
            return 'pyautogui'
    
    # 尝试 Win32
    move_mouse_win32(target_x, target_y)
    time.sleep(0.1)
    nx, ny = get_mouse_pos()
    print(f"  Win32 结果：{nx}, {ny}")
    if abs(nx - target_x) < 5 and abs(ny - target_y) < 5:
        print("  ✓ Win32 有效")
        return 'win32'
    
    print("  ✗ 两种方法都无效")
    return None

# ============ 目标检测 ============
def detect_targets(gray, cx, cy, fov):
    """检测人形目标"""
    h, w = gray.shape[:2]
    targets = []
    
    x1, y1 = max(0, cx - fov), max(0, cy - fov)
    x2, y2 = min(w, cx + fov), min(h, cy + fov)
    roi = gray[y1:y2, x1:x2]
    
    if roi.size == 0:
        return []
    
    # 高斯模糊
    blurred = cv2.GaussianBlur(roi, (5, 5), 0)
    
    # 自适应阈值
    thresh = cv2.adaptiveThreshold(blurred, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
                                   cv2.THRESH_BINARY_INV, 11, 2)
    
    # 形态学
    kernel = np.ones((4, 4), np.uint8)
    morph = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel, iterations=2)
    
    # 轮廓
    contours, _ = cv2.findContours(morph, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    for c in contours:
        area = cv2.contourArea(c)
        if 1500 < area < 60000:
            x, y, bw, bh = cv2.boundingRect(c)
            aspect = bw / bh if bh > 0 else 0
            
            # 人形：瘦高
            if 0.3 < aspect < 0.75 and bh > 40:
                gx = x1 + x + bw // 2
                gy = y1 + y + int(bh * CFG['head_offset'])
                targets.append({
                    'x': gx, 'y': gy, 'w': bw, 'h': bh,
                    'dist': abs(gx - cx) + abs(gy - cy)
                })
    
    targets.sort(key=lambda t: t['dist'])
    return targets

# ============ 自瞄主循环 ============
def aim_loop():
    """自瞄主循环"""
    mouse_method = 'pyautogui'  # 默认使用 pyautogui
    
    with mss.mss() as sct:
        mon = sct.monitors[1]
        cx, cy = mon["width"] // 2, mon["height"] // 2
        
        aim_state = "idle"
        aim_start = 0
        lock_time = 0
        fire_time = 0
        start_pos = (0, 0)
        
        print(f"\n[自瞄] 循环启动 - 检测中心：{cx}x{cy}")
        
        while state.running:
            try:
                # 截图
                shot = sct.grab(mon)
                img = np.array(shot)
                gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
                
                # 获取鼠标位置
                mx, my = get_mouse_pos()
                
                if state.aiming:
                    # 检测
                    targets = detect_targets(gray, cx, cy, CFG['fov'])
                    
                    if targets:
                        with state.lock:
                            state.stats['detects'] += 1
                        
                        target = targets[0]
                        tx, ty = target['x'], target['y']
                        dist = abs(tx - mx) + abs(ty - my)
                        
                        if state.debug:
                            print(f"[检测] 目标：{tx}x{ty}, 距离：{dist}")
                        
                        # 状态机
                        if aim_state == "idle":
                            aim_state = "aiming"
                            aim_start = time.time()
                            start_pos = (mx, my)
                        
                        elif aim_state == "aiming":
                            elapsed = (time.time() - aim_start) * 1000
                            progress = min(1.0, elapsed / CFG['aim_time_ms'])
                            
                            # 移动鼠标
                            ax = int(start_pos[0] + (tx - start_pos[0]) * progress)
                            ay = int(start_pos[1] + (ty - start_pos[1]) * progress)
                            
                            if mouse_method == 'pyautogui':
                                move_mouse_pyautogui(ax, ay)
                            else:
                                move_mouse_win32(ax, ay)
                            
                            # 检查锁定
                            if dist <= CFG['lock_pixels']:
                                aim_state = "locked"
                                lock_time = time.time()
                                with state.lock:
                                    state.stats['locks'] += 1
                                print(f"[锁定] {datetime.now().strftime('%H:%M:%S.%f')[:-3]}")
                        
                        elif aim_state == "locked":
                            if (time.time() - lock_time) * 1000 >= CFG['fire_delay_ms']:
                                click_mouse()
                                aim_state = "firing"
                                fire_time = time.time()
                                with state.lock:
                                    state.stats['shots'] += 1
                                print(f"[开枪] {datetime.now().strftime('%H:%M:%S.%f')[:-3]}")
                        
                        elif aim_state == "firing":
                            if (time.time() - fire_time) * 1000 >= CFG['fire_interval_ms']:
                                aim_state = "aiming"
                                aim_start = time.time()
                                start_pos = get_mouse_pos()
                    else:
                        aim_state = "idle"
                else:
                    aim_state = "idle"
                
            except Exception as e:
                print(f"[错误] {type(e).__name__}: {e}")
            
            time.sleep(0.002)

def hotkey_loop():
    """热键"""
    try:
        import keyboard
        has_kb = True
    except:
        has_kb = False
        print("[!] keyboard 不可用，部分热键可能无效")
    
    print("\n" + "=" * 55)
    print("  CS2 自瞄锁头 - 测试版")
    print("  作者：Claw 🐾")
    print("=" * 55)
    print("\n[热键]")
    print("  F1 - 启动/停止自瞄")
    print("  F2 - 退出程序")
    print("  F3 - 测试鼠标移动")
    print("  F4 - 开关调试信息")
    print("\n[状态] 就绪")
    
    last = {'f1': 0, 'f2': 0, 'f3': 0, 'f4': 0}
    cd = 0.3
    
    while state.running:
        try:
            now = time.time()
            if has_kb:
                import keyboard
                
                if keyboard.is_pressed('f1') and now - last['f1'] > cd:
                    last['f1'] = now
                    state.aiming = not state.aiming
                    s = "🟢 已启动" if state.aiming else "🔴 已停止"
                    print(f"\n[自瞄] {s}")
                
                if keyboard.is_pressed('f2') and now - last['f2'] > cd:
                    last['f2'] = now
                    print("\n[退出] 关闭...")
                    state.running = False
                    break
                
                if keyboard.is_pressed('f3') and now - last['f3'] > cd:
                    last['f3'] = now
                    test_mouse_move()
                
                if keyboard.is_pressed('f4') and now - last['f4'] > cd:
                    last['f4'] = now
                    state.debug = not state.debug
                    print(f"\n[调试] {'开启' if state.debug else '关闭'}")
        
        except Exception as e:
            print(f"[热键] {e}")
        
        time.sleep(0.02)

def main():
    print("[CS2 自瞄锁头 - 测试版]")
    print("=" * 55)
    
    # 先测试核心功能
    print("\n[初始化] 测试核心功能...")
    
    if not test_screenshot():
        print("\n[错误] 截图功能失败，程序无法继续")
        return
    
    mouse_method = test_mouse_move()
    if not mouse_method:
        print("\n[警告] 鼠标控制可能有问题，但继续运行")
    
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
    
    time.sleep(0.3)
    
    # 打印统计
    print("\n" + "=" * 55)
    print("[统计]")
    print(f"  检测次数：{state.stats['detects']}")
    print(f"  锁定次数：{state.stats['locks']}")
    print(f"  开枪次数：{state.stats['shots']}")
    print("\n[退出] 再见")

if __name__ == "__main__":
    main()
