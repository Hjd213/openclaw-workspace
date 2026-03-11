from docx import Document
import os

path = r'C:\Users\bljd5\Desktop\简历'
files = [f for f in os.listdir(path) if f.endswith('.docx') and not f.startswith('~$')]

for f in files:
    print(f'=== {f} ===')
    doc = Document(os.path.join(path, f))
    for i, p in enumerate(doc.paragraphs[:30]):
        if p.text.strip():
            print(f'  [{i}] {p.text[:200]}')
    print()
