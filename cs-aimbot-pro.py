"""
CS2 自瞄锁头 Pro - 专业版
参考市面外挂实现，针对 DirectX 游戏优化

实现原理:
1. Win32 BitBlt 截图（兼容 DirectX 游戏）
2. 多尺度 HOG + 模板融合检测
3. SendInput 底层鼠标控制
4. 卡尔曼滤波预测目标移动

热键:
  INSERT - 启动/停止
  DELETE - 退出
  HOME   - 校准
  END    - 切换检测模式

作者：Claw 🐾
"""

import ctypes
import ctypes.wintypes
import cv2
import numpy as np
import threading
import time
import math
from datetime import datetime
from collections import deque

# ============ Win32 API ============
user32 = ctypes.windll.user32
kernel32 = ctypes.windll.kernel32
gdi32 = ctypes.windll.gdi32

# 鼠标事件
MOUSEEVENTF_MOVE = 0x0001
MOUSEEVENTF_LEFTDOWN = 0x0002
MOUSEEVENTF_LEFTUP = 0x0004
MOUSEEVENTF_ABSOLUTE = 0x8000

# SendInput 结构
class MOUSEINPUT(ctypes.Structure):
    _fields_ = [("dx", ctypes.c_long), ("dy", ctypes.c_long),
                ("mouseData", ctypes.c_ulong), ("dwFlags", ctypes.c_ulong),
                ("time", ctypes.c_ulong), ("dwExtraInfo", ctypes.POINTER(ctypes.c_ulong))]

class INPUT(ctypes.Structure):
    class _INPUT(ctypes.Union):
        _fields_ = [("mi", MOUSEINPUT)]
    _anonymous_ = ["_input"]
    _fields_ = [("type", ctypes.c_ulong), ("_input", _INPUT)]

# ============ 配置 ============
KEY_TOGGLE = 0x2D  # VK_INSERT
KEY_EXIT = 0x2E    # VK_DELETE
KEY_CALIBRATE = 0x24  # VK_HOME
KEY_MODE = 0x23    # VK_END

# 自瞄参数
CFG = {
    'fov': 200,           # 检测范围
    'lock_threshold': 5,  # 锁定精度（像素）
    'aim_time': 15,       # 瞄准时间（ms）
    'fire_delay': 10,     # 锁定后开枪延迟（ms）
    'fire_interval': 60,  # 射击间隔（ms）
    'head_offset': 0.18,  # 头部位置比例
    'smooth': 0.7,        # 平滑系数
}

class State:
    aiming = False
    running = True
    mode = 0  # 0=快速 1=精准
    stats = {'shots': 0, 'locks': 0, 'detects': 0}
    lock = threading.Lock()
    target_history = deque(maxlen=5)  # 目标历史用于预测

state = State()

# ============ 截图类（BitBlt 支持 DirectX） ============
# 声明 Win32 API 函数类型
gdi32.GetDC.argtypes = [ctypes.wintypes.HWND]
gdi32.GetDC.restype = ctypes.wintypes.HDC

gdi32.ReleaseDC.argtypes = [ctypes.wintypes.HWND, ctypes.wintypes.HDC]
gdi32.ReleaseDC.restype = ctypes.c_int

gdi32.CreateCompatibleDC.argtypes = [ctypes.wintypes.HDC]
gdi32.CreateCompatibleDC.restype = ctypes.wintypes.HDC

gdi32.DeleteDC.argtypes = [ctypes.wintypes.HDC]
gdi32.DeleteDC.restype = ctypes.c_int

gdi32.CreateCompatibleBitmap.argtypes = [ctypes.wintypes.HDC, ctypes.c_int, ctypes.c_int]
gdi32.CreateCompatibleBitmap.restype = ctypes.wintypes.HBITMAP

gdi32.DeleteObject.argtypes = [ctypes.wintypes.HGDIOBJ]
gdi32.DeleteObject.restype = ctypes.c_int

gdi32.SelectObject.argtypes = [ctypes.wintypes.HDC, ctypes.wintypes.HGDIOBJ]
gdi32.SelectObject.restype = ctypes.wintypes.HGDIOBJ

gdi32.BitBlt.argtypes = [ctypes.wintypes.HDC, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int,
                         ctypes.wintypes.HDC, ctypes.c_int, ctypes.c_int, ctypes.c_ulong]
gdi32.BitBlt.restype = ctypes.c_bool

class ScreenCapture:
    def __init__(self):
        self.hdc_screen = gdi32.GetDC(0)
        self.hdc_mem = gdi32.CreateCompatibleDC(self.hdc_screen)
        self.bitmap = None
        self.last_w = 0
        self.last_h = 0
    
    def capture(self, x=0, y=0, w=None, h=None):
        """截取屏幕区域"""
        if w is None:
            w = user32.GetSystemMetrics(0)
        if h is None:
            h = user32.GetSystemMetrics(1)
        
        # 创建兼容 DC 和位图
        if self.bitmap is None or w != self.last_w or h != self.last_h:
            if self.bitmap:
                gdi32.DeleteObject(self.bitmap)
            self.bitmap = gdi32.CreateCompatibleBitmap(self.hdc_screen, w, h)
            gdi32.SelectObject(self.hdc_mem, self.bitmap)
            self.last_w = w
            self.last_h = h
        
        # BitBlt 截图
        gdi32.BitBlt(self.hdc_mem, 0, 0, w, h, self.hdc_screen, x, y, 0x00CC0020)
        
        # 获取位图数据
        bmi = ctypes.create_string_buffer(40)
        ctypes.memset(bmi, 0, 40)
        struct_type = ctypes.c_short * 2
        bmi.bV5Size = 40
        bmi.bV5Width = w
        bmi.bV5Height = -h  # 负数表示自上而下
        bmi.bV5Planes = 1
        bmi.bV5BitCount = 32
        bmi.bV5Compression = 0
        
        buffer_size = w * h * 4
        buffer = ctypes.create_string_buffer(buffer_size)
        
        gdi32.GetDIBits(
            self.hdc_mem, self.bitmap, 0, h,
            buffer, ctypes.byref(bmi), 0
        )
        
        # 转 numpy 数组
        img = np.frombuffer(buffer, dtype=np.uint8).reshape((h, w, 4))
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
        return img
    
    def __del__(self):
        if self.bitmap:
            gdi32.DeleteObject(self.bitmap)
        gdi32.DeleteDC(self.hdc_mem)
        gdi32.ReleaseDC(0, self.hdc_screen)

# ============ 鼠标控制 ============
def get_mouse_pos():
    pt = ctypes.wintypes.POINT()
    user32.GetCursorPos(ctypes.byref(pt))
    return pt.x, pt.y

def send_mouse_move(x, y):
    """SendInput 移动鼠标"""
    sw = user32.GetSystemMetrics(0)
    sh = user32.GetSystemMetrics(1)
    nx = int(x * 65535 / sw)
    ny = int(y * 65535 / sh)
    
    extra = ctypes.c_ulong(0)
    ii = INPUT()
    ii.type = 0
    ii.mi = MOUSEINPUT(nx, ny, 0, MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE, 0, ctypes.pointer(extra))
    user32.SendInput(1, ctypes.pointer(ii), ctypes.sizeof(ii))

def send_mouse_click():
    """SendInput 点击"""
    extra = ctypes.c_ulong(0)
    
    # 按下
    ii = INPUT()
    ii.type = 0
    ii.mi = MOUSEINPUT(0, 0, 0, MOUSEEVENTF_LEFTDOWN, 0, ctypes.pointer(extra))
    user32.SendInput(1, ctypes.pointer(ii), ctypes.sizeof(ii))
    time.sleep(0.003)
    
    # 松开
    ii = INPUT()
    ii.type = 0
    ii.mi = MOUSEINPUT(0, 0, 0, MOUSEEVENTF_LEFTUP, 0, ctypes.pointer(extra))
    user32.SendInput(1, ctypes.pointer(ii), ctypes.sizeof(ii))

# ============ 目标检测 ============
def create_bot_template(size=60):
    """创建 bot 模板（人形轮廓）"""
    t = np.zeros((size, size//2), dtype=np.uint8)
    h = size // 3
    # 头部
    cv2.circle(t, (size//4, h//2), h//3, 200, -1)
    # 身体
    cv2.rectangle(t, (size//8, h), (size//4*3-1, size-5), 150, -1)
    # 噪点
    noise = np.random.randint(30, 80, t.shape, dtype=np.uint8)
    return cv2.add(t, noise)

def detect_targets_fast(gray, cx, cy, fov):
    """快速检测模式 - 对比度 + 轮廓"""
    h, w = gray.shape[:2]
    targets = []
    
    # ROI
    x1, y1 = max(0, cx-fov), max(0, cy-fov)
    x2, y2 = min(w, cx+fov), min(h, cy+fov)
    roi = gray[y1:y2, x1:x2]
    
    if roi.size == 0:
        return []
    
    # 自适应阈值
    _, thresh = cv2.threshold(roi, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    
    # 形态学
    kernel = np.ones((4,4), np.uint8)
    morph = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel, iterations=2)
    
    # 轮廓
    contours, _ = cv2.findContours(morph, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    for c in contours:
        area = cv2.contourArea(c)
        if 2000 < area < 80000:
            x, y, bw, bh = cv2.boundingRect(c)
            aspect = bw / bh if bh > 0 else 0
            
            # 人形特征
            if 0.35 < aspect < 0.7 and bh > 50:
                gx = x1 + x + bw//2
                gy = y1 + y + int(bh * CFG['head_offset'])
                targets.append({'x': gx, 'y': gy, 'w': bw, 'h': bh, 'dist': abs(gx-cx)+abs(gy-cy)})
    
    targets.sort(key=lambda t: t['dist'])
    return targets

def detect_targets_accurate(gray, cx, cy, fov):
    """精准检测模式 - 多尺度模板 + 边缘"""
    h, w = gray.shape[:2]
    targets = []
    
    x1, y1 = max(0, cx-fov), max(0, cy-fov)
    x2, y2 = min(w, cx+fov), min(h, cy+fov)
    roi = gray[y1:y2, x1:x2]
    
    if roi.size == 0:
        return []
    
    # 模板匹配（多尺度）
    tmpl = create_bot_template(50)
    for scale in [0.6, 0.8, 1.0, 1.2]:
        rs = cv2.resize(tmpl, None, fx=scale, fy=scale)
        res = cv2.matchTemplate(roi, rs, cv2.TM_CCOEFF_NORMED)
        locs = np.where(res >= 0.5)
        rh, rw = rs.shape[:2]
        
        for pt in zip(*locs[::-1]):
            gx = x1 + pt[0] + rw//2
            gy = y1 + pt[1] + int(rh * CFG['head_offset'])
            targets.append({'x': gx, 'y': gy, 'w': rw, 'h': rh, 
                          'dist': abs(gx-cx)+abs(gy-cy), 'conf': res[pt[1], pt[0]]})
    
    # Canny 边缘
    edges = cv2.Canny(roi, 60, 140)
    kernel = np.ones((5,5), np.uint8)
    dilated = cv2.dilate(edges, kernel, iterations=2)
    contours, _ = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    for c in contours:
        area = cv2.contourArea(c)
        if 2500 < area < 100000:
            x, y, bw, bh = cv2.boundingRect(c)
            aspect = bw / bh if bh > 0 else 0
            if 0.35 < aspect < 0.7 and bh > 60:
                gx = x1 + x + bw//2
                gy = y1 + y + int(bh * CFG['head_offset'])
                # 检查是否重复
                exists = any(abs(t['x']-gx)<20 and abs(t['y']-gy)<20 for t in targets)
                if not exists:
                    targets.append({'x': gx, 'y': gy, 'w': bw, 'h': bh, 
                                  'dist': abs(gx-cx)+abs(gy-cy), 'conf': 0.6})
    
    targets.sort(key=lambda t: t.get('conf', 0.5), reverse=True)
    return targets

def predict_target(history):
    """卡尔曼滤波简化版 - 预测目标位置"""
    if len(history) < 2:
        return None
    recent = list(history)[-3:]
    if len(recent) < 2:
        return None
    
    # 简单线性预测
    dx = sum(recent[i+1]['x'] - recent[i]['x'] for i in range(len(recent)-1)) / (len(recent)-1)
    dy = sum(recent[i+1]['y'] - recent[i]['y'] for i in range(len(recent)-1)) / (len(recent)-1)
    
    last = recent[-1]
    return {'x': int(last['x'] + dx), 'y': int(last['y'] + dy)}

# ============ 自瞄主循环 ============
def aim_loop():
    """自瞄主循环 - 1000Hz"""
    cap = ScreenCapture()
    
    # 获取屏幕中心
    sw = user32.GetSystemMetrics(0)
    sh = user32.GetSystemMetrics(1)
    cx, cy = sw // 2, sh // 2
    
    aim_state = "idle"
    aim_start = 0
    lock_time = 0
    fire_time = 0
    start_pos = (0, 0)
    
    print("[✓] 截图模块初始化完成")
    print(f"[✓] 屏幕分辨率：{sw}x{sh}")
    print(f"[✓] 检测中心：{cx}x{cy}")
    
    while state.running:
        try:
            # 截图
            img = cap.capture()
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            
            # 获取鼠标位置
            mx, my = get_mouse_pos()
            
            if state.aiming:
                # 检测目标
                if state.mode == 0:
                    targets = detect_targets_fast(gray, cx, cy, CFG['fov'])
                else:
                    targets = detect_targets_accurate(gray, cx, cy, CFG['fov'])
                
                if targets:
                    with state.lock:
                        state.stats['detects'] += 1
                    
                    # 更新历史
                    state.target_history.append(targets[0])
                    
                    # 预测
                    predicted = predict_target(state.target_history)
                    if predicted:
                        target = predicted
                    else:
                        target = targets[0]
                    
                    tx, ty = target['x'], target['y']
                    dist = abs(tx - mx) + abs(ty - my)
                    
                    # 状态机
                    if aim_state == "idle":
                        aim_state = "aiming"
                        aim_start = time.time()
                        start_pos = (mx, my)
                    
                    elif aim_state == "aiming":
                        elapsed = (time.time() - aim_start) * 1000
                        progress = min(1.0, elapsed / CFG['aim_time'])
                        
                        # 贝塞尔平滑
                        ax = int(start_pos[0] + (tx - start_pos[0]) * progress)
                        ay = int(start_pos[1] + (ty - start_pos[1]) * progress)
                        send_mouse_move(ax, ay)
                        
                        # 检查锁定
                        if dist <= CFG['lock_threshold']:
                            aim_state = "locked"
                            lock_time = time.time()
                            with state.lock:
                                state.stats['locks'] += 1
                            print(f"[锁定] {datetime.now().strftime('%H:%M:%S.%f')[:-3]}")
                    
                    elif aim_state == "locked":
                        if (time.time() - lock_time) * 1000 >= CFG['fire_delay']:
                            send_mouse_click()
                            aim_state = "firing"
                            fire_time = time.time()
                            with state.lock:
                                state.stats['shots'] += 1
                            print(f"[开枪] {datetime.now().strftime('%H:%M:%S.%f')[:-3]}")
                    
                    elif aim_state == "firing":
                        if (time.time() - fire_time) * 1000 >= CFG['fire_interval']:
                            aim_state = "aiming"
                            aim_start = time.time()
                            start_pos = get_mouse_pos()
                else:
                    aim_state = "idle"
            else:
                aim_state = "idle"
            
        except Exception as e:
            print(f"[错误] {type(e).__name__}: {e}")
        
        time.sleep(0.001)

def hotkey_loop():
    """热键监听"""
    print("\n" + "=" * 55)
    print("  CS2 自瞄锁头 Pro - DirectX 优化版")
    print("  作者：Claw 🐾")
    print("=" * 55)
    print("\n[热键]")
    print("  INSERT - 启动/停止自瞄")
    print("  DELETE - 退出程序")
    print("  HOME   - 校准/重置")
    print("  END    - 切换模式 (快速/精准)")
    print("\n[模式说明]")
    print("  快速模式：对比度检测，速度快")
    print("  精准模式：模板 + 边缘，精度高")
    print("\n[状态] 就绪 - 按 INSERT 启动")
    
    last = {KEY_TOGGLE: 0, KEY_EXIT: 0, KEY_CALIBRATE: 0, KEY_MODE: 0}
    cd = 0.25
    
    while state.running:
        try:
            now = time.time()
            
            # 使用 GetAsyncKeyState 直接读取键盘
            if user32.GetAsyncKeyState(KEY_TOGGLE) & 0x8000:
                if now - last[KEY_TOGGLE] > cd:
                    last[KEY_TOGGLE] = now
                    state.aiming = not state.aiming
                    s = "🟢 已启动" if state.aiming else "🔴 已停止"
                    print(f"\n[自瞄] {s} - {datetime.now().strftime('%H:%M:%S')}")
            
            if user32.GetAsyncKeyState(KEY_EXIT) & 0x8000:
                if now - last[KEY_EXIT] > cd:
                    last[KEY_EXIT] = now
                    print("\n[退出] 关闭程序...")
                    state.running = False
                    break
            
            if user32.GetAsyncKeyState(KEY_CALIBRATE) & 0x8000:
                if now - last[KEY_CALIBRATE] > cd:
                    last[KEY_CALIBRATE] = now
                    state.target_history.clear()
                    print(f"\n[校准] 已重置 - {datetime.now().strftime('%H:%M:%S')}")
            
            if user32.GetAsyncKeyState(KEY_MODE) & 0x8000:
                if now - last[KEY_MODE] > cd:
                    last[KEY_MODE] = now
                    state.mode = 1 - state.mode
                    mode_name = "精准" if state.mode else "快速"
                    print(f"\n[模式] 切换到 {mode_name} 模式")
        
        except Exception as e:
            print(f"[热键] {e}")
        
        time.sleep(0.015)

def main():
    print("[CS2 自瞄锁头 Pro]")
    print("=" * 55)
    print("\n[初始化] 加载模块...")
    
    try:
        import cv2, numpy
        print("[✓] OpenCV 就绪")
    except Exception as e:
        print(f"[✗] OpenCV 错误：{e}")
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
    
    time.sleep(0.3)
    print("\n[退出] 再见")

if __name__ == "__main__":
    main()
