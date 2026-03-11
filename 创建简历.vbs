Set word = CreateObject("Word.Application")
word.Visible = False
Set doc = word.Documents.Add()
Set sel = word.Selection

' 标题 - 姓名
sel.Font.Size = 18
sel.Font.Bold = True
sel.Font.Name = "微软雅黑"
sel.ParagraphFormat.Alignment = 1  ' 居中
sel.TypeText "黄健东"
sel.TypeParagraph()

' 联系信息
sel.Font.Size = 10.5
sel.Font.Bold = False
sel.Font.Name = "宋体"
sel.ParagraphFormat.Alignment = 1  ' 居中
sel.TypeText "手机：+86 19973510193    邮箱：120241280105@ncepu.edu.cn    地址：中国北京市海淀区"
sel.TypeParagraph()
sel.TypeParagraph()

' 教育背景
sel.Font.Size = 12
sel.Font.Bold = True
sel.ParagraphFormat.Alignment = 0  ' 左对齐
sel.TypeText "教育背景"
sel.TypeParagraph()
sel.Font.Size = 10.5
sel.Font.Bold = False
sel.TypeText "华北电力大学 · 工学学士    2024.09 - 至今"
sel.TypeParagraph()
sel.TypeText "GPA：3.95/5.0，专业排名第 3"
sel.TypeParagraph()
sel.TypeText "主修课程：高等数学（98 分）、C 程序设计（92 分）、程序设计实验（92 分）、计算机导论（90 分）"
sel.TypeParagraph()
sel.TypeParagraph()

' 项目/研究经历
sel.Font.Size = 12
sel.Font.Bold = True
sel.TypeText "项目/研究经历"
sel.TypeParagraph()
sel.Font.Size = 10.5
sel.Font.Bold = False
sel.TypeText "清华大学 | 科研助理    2025.07 - 2025.08"
sel.TypeParagraph()
sel.Font.Italic = True
sel.TypeText "项目：数智技术赋能医疗改革研究（中国卫生经济学会资助）"
sel.Font.Italic = False
sel.TypeParagraph()
sel.TypeText "  • 主导中美日三国数智医疗政策对比分析，提炼可借鉴策略"
sel.TypeParagraph()
sel.TypeText "  • 系统分析 20+ 项关键政策，撰写逾万字政策分析报告及 2 份医疗 AI 国家战略分析报告"
sel.TypeParagraph()
sel.TypeText "  • 熟练运用 AI 工具辅助研究"
sel.TypeParagraph()
sel.TypeParagraph()

sel.Font.Size = 10.5
sel.Font.Bold = False
sel.TypeText "国家级大学生创新创业训练计划 | 项目负责人    2024.09 - 至今"
sel.TypeParagraph()
sel.Font.Italic = True
sel.TypeText "项目：指尖上的非遗——文化遗产数字化与交互程序设计"
sel.Font.Italic = False
sel.TypeParagraph()
sel.TypeText "  • 获校级立项（录取率<15%）"
sel.TypeParagraph()
sel.TypeText "  • 组建 4 人跨学科团队，实现"非遗传播年轻化"核心目标"
sel.TypeParagraph()
sel.TypeParagraph()

sel.Font.Size = 10.5
sel.Font.Bold = False
sel.TypeText "全国网络安全 CTF 竞赛    2024.08 - 至今"
sel.TypeParagraph()
sel.TypeText "  • 掌握虚拟机配置、Kali Linux 系统操作"
sel.TypeParagraph()
sel.TypeText "  • 具备 C 语言编程基础"
sel.TypeParagraph()
sel.TypeParagraph()

sel.Font.Size = 10.5
sel.Font.Bold = False
sel.TypeText "中国大学生数学建模竞赛    2025.04 - 2025.09"
sel.TypeParagraph()
sel.TypeText "  • 72 小时限时竞赛，负责数学建模与算法开发"
sel.TypeParagraph()
sel.TypeText "  • 使用 MATLAB 完成模型求解"
sel.TypeParagraph()
sel.TypeParagraph()

' 技能与工具
sel.Font.Size = 12
sel.Font.Bold = True
sel.TypeText "技能与工具"
sel.TypeParagraph()
sel.Font.Size = 10.5
sel.Font.Bold = False
sel.TypeText "编程语言：C、MATLAB"
sel.TypeParagraph()
sel.TypeText "开发工具：Visual Studio、C-Free"
sel.TypeParagraph()
sel.TypeText "其他技能：AI 工具应用、Linux 基础操作"
sel.TypeParagraph()
sel.TypeParagraph()

' 荣誉与证书
sel.Font.Size = 12
sel.Font.Bold = True
sel.TypeText "荣誉与证书"
sel.TypeParagraph()
sel.Font.Size = 10.5
sel.Font.Bold = False
sel.TypeText "大学英语六级（CET-6）"
sel.TypeParagraph()
sel.TypeText "大学英语四级（CET-4）"
sel.TypeParagraph()
sel.TypeParagraph()

' 自我评价
sel.Font.Size = 12
sel.Font.Bold = True
sel.TypeText "自我评价"
sel.TypeParagraph()
sel.Font.Size = 10.5
sel.Font.Bold = False
sel.TypeText "乐观积极、勤奋好学，成绩优异。对计算机技术有浓厚热情，专业基础扎实。具备良好的 C 语言编程能力、沟通表达能力和团队协作经验。"
sel.TypeParagraph()

' 保存
doc.SaveAs "C:\Users\bljd5\Desktop\中文简历 hjd（第一版）.docx"
word.Quit()
