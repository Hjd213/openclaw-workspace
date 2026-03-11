from docx import Document
from docx.shared import Pt, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
import os

# 你的简历数据
data = {
    'name': '黄健东',
    'phone': '+86 19973510193',
    'email': '120241280105@ncepu.edu.cn',
    'address': '中国北京市海淀区',
    'school': '华北电力大学',
    'degree': '工学学士',
    'date': '2024.09 - 至今',
    'gpa': 'GPA：3.95/5.0，专业排名第 3',
    'courses': '主修课程：高等数学（98 分）、C 程序设计（92 分）、程序设计实验（92 分）、计算机导论（90 分）',
    'projects': [
        {
            'company': '清华大学',
            'role': '科研助理',
            'date': '2025.07 - 2025.08',
            'desc': '数智技术赋能医疗改革研究（中国卫生经济学会资助）',
            'details': [
                '主导中美日三国数智医疗政策对比分析，提炼可借鉴策略',
                '系统分析 20+ 项关键政策，撰写逾万字政策分析报告及 2 份医疗 AI 国家战略分析报告',
                '熟练运用 AI 工具辅助研究'
            ]
        },
        {
            'company': '国家级大学生创新创业训练计划',
            'role': '项目负责人',
            'date': '2024.09 - 至今',
            'desc': '指尖上的非遗——文化遗产数字化与交互程序设计',
            'details': [
                '获校级立项（录取率<15%）',
                '组建 4 人跨学科团队，实现非遗传播年轻化核心目标'
            ]
        },
        {
            'company': '全国网络安全 CTF 竞赛',
            'role': '参赛选手',
            'date': '2024.08 - 至今',
            'desc': '',
            'details': [
                '掌握虚拟机配置、Kali Linux 系统操作',
                '具备 C 语言编程基础'
            ]
        },
        {
            'company': '中国大学生数学建模竞赛',
            'role': '建模手',
            'date': '2025.04 - 2025.09',
            'desc': '',
            'details': [
                '72 小时限时竞赛，负责数学建模与算法开发',
                '使用 MATLAB 完成模型求解'
            ]
        }
    ],
    'skills': [
        '编程语言：C、MATLAB',
        '开发工具：Visual Studio、C-Free',
        '其他技能：AI 工具应用、Linux 基础操作'
    ],
    'certificates': [
        '大学英语六级（CET-6）',
        '大学英语四级（CET-4）'
    ],
    'self_eval': '乐观积极、勤奋好学，成绩优异。对计算机技术有浓厚热情，专业基础扎实。具备良好的 C 语言编程能力、沟通表达能力和团队协作经验。'
}

def fill_template(template_path, output_path):
    doc = Document(template_path)
    
    # 遍历所有段落，替换内容
    for para in doc.paragraphs:
        text = para.text
        
        # 替换姓名
        if '稻小壳' in text or '姓名' in text:
            para.text = text.replace('稻小壳', data['name']).replace('姓名', data['name'])
        
        # 替换电话
        if '12345678901' in text or '电话' in text:
            para.text = text.replace('12345678901', data['phone'])
        
        # 替换邮箱
        if 'kingsoft@.com' in text or '邮箱' in text:
            para.text = text.replace('kingsoft@.com', data['email'])
        
        # 替换学校
        if 'XX 大学' in text or '学校名称' in text:
            para.text = text.replace('XX 大学', data['school'])
        if '某某大学' in text:
            para.text = text.replace('某某大学', data['school'])
        
        # 替换专业
        if '机械' in text and '专业' in text:
            para.text = text.replace('机械', '计算机')
        
        # 替换时间
        if '20XX' in text or '20 某某' in text:
            para.text = text.replace('20XX', data['date'].split(' - ')[0]).replace('20 某某', data['date'])
    
    doc.save(output_path)
    print(f'已生成：{output_path}')

# 处理三个模板
template_dir = r'C:\Users\bljd5\Desktop\简历'
output_dir = r'C:\Users\bljd5\Desktop\简历'

templates = [
    ('稻小壳 - 简历.docx', '黄健东 - 简历（模板 1）.docx'),
    ('稻小壳.docx', '黄健东 - 简历（模板 2）.docx'),
    ('稻小壳求职意向.docx', '黄健东 - 简历（求职意向）.docx')
]

for template, output in templates:
    template_path = os.path.join(template_dir, template)
    output_path = os.path.join(output_dir, output)
    if os.path.exists(template_path):
        fill_template(template_path, output_path)
    else:
        print(f'模板不存在：{template}')

print('\n完成！')
