"""Export this project documentation to a browser reading copy and Word."""
from pathlib import Path
import posixpath
import re
from urllib.parse import quote

import markdown
from lxml import html
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.opc.constants import RELATIONSHIP_TYPE as RT

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / 'WEEK_3_DOCUMENTATION.md'
text = SOURCE.read_text()
body = markdown.markdown(text, extensions=['tables', 'fenced_code', 'toc'])
tree = html.fragment_fromstring(body, create_parent='div')
doc = Document()
section = doc.sections[0]
section.top_margin = section.bottom_margin = Inches(.65)
section.left_margin = section.right_margin = Inches(.7)
normal = doc.styles['Normal']
normal.font.name = 'Calibri'
normal.font.size = Pt(11)
normal.paragraph_format.space_after = Pt(7)
normal.paragraph_format.line_spacing = 1.1
for name, size in [('Title', 28), ('Heading 1', 20), ('Heading 2', 15), ('Heading 3', 12)]:
    style = doc.styles[name]
    style.font.name = 'Calibri'
    style.font.size = Pt(size)
    style.font.color.rgb = RGBColor.from_string('182B4D')
    style.paragraph_format.keep_with_next = True
    style.paragraph_format.space_before = Pt(14)
doc.core_properties.title = 'Agentic UI Test Automation and Movies'
doc.core_properties.author = 'Tarun Khurana'
doc.core_properties.subject = 'Generative AI Academy Week 3 capstone documentation'
doc.core_properties.keywords = 'LangGraph, LangChain, Appium, Flutter, testing'

def slug(text):
    return re.sub(r'[^a-z0-9_]', '_', text.lower())[:36]

def target_url(target):
    if target.startswith('#') or '://' in target:
        return target
    path, sep, fragment = target.partition('#')
    path = posixpath.normpath(posixpath.join('week3-project-automated-testing/docs', path))
    kind = 'tree' if target.endswith('/') else 'blob'
    return ('https://github.com/tarunkhurana2015/ai-certification-gen-academy/'
            + kind + '/main/' + quote(path, safe='/') + (sep + fragment if sep else ''))

def hyperlink(paragraph, label, target, bold=False):
    element = OxmlElement('w:hyperlink')
    if target.startswith('#'):
        element.set(qn('w:anchor'), slug(target[1:]))
    else:
        rid = paragraph.part.relate_to(target_url(target), RT.HYPERLINK, is_external=True)
        element.set(qn('r:id'), rid)
    run = OxmlElement('w:r')
    props = OxmlElement('w:rPr')
    color = OxmlElement('w:color'); color.set(qn('w:val'), '5546A4'); props.append(color)
    underline = OxmlElement('w:u'); underline.set(qn('w:val'), 'single'); props.append(underline)
    if bold: props.append(OxmlElement('w:b'))
    run.append(props)
    content = OxmlElement('w:t'); content.text = label; run.append(content)
    element.append(run); paragraph._p.append(element)

def inline(node, paragraph, bold=False, code=False):
    def add(value):
        if not value: return
        run = paragraph.add_run(value); run.bold = bold
        if code:
            run.font.name = 'Consolas'; run.font.size = Pt(9)
    add(node.text)
    for child in node:
        if child.tag == 'a':
            hyperlink(paragraph, ''.join(child.itertext()), child.get('href', ''), bold)
        elif child.tag == 'br': paragraph.add_run().add_break()
        elif child.tag == 'img':
            picture = paragraph.add_run().add_picture(str(ROOT / child.get('src')), width=Inches(7.0))
            picture._inline.docPr.set('descr', child.get('alt', 'Architecture diagram'))
        else:
            inline(child, paragraph, bold or child.tag in ('strong', 'b'), code or child.tag == 'code')
        add(child.tail)

bookmark_id = 0
for element in tree:
    tag = element.tag
    if tag in ('h1', 'h2', 'h3', 'h4'):
        title = ''.join(element.itertext())
        p = doc.add_paragraph(title, 'Title' if tag == 'h1' else f'Heading {int(tag[1])-1}')
        if element.get('id'):
            bookmark_id += 1
            start = OxmlElement('w:bookmarkStart'); start.set(qn('w:id'), str(bookmark_id)); start.set(qn('w:name'), slug(element.get('id')))
            end = OxmlElement('w:bookmarkEnd'); end.set(qn('w:id'), str(bookmark_id))
            p._p.insert(0, start); p._p.append(end)
    elif tag == 'p': inline(element, doc.add_paragraph())
    elif tag in ('ul', 'ol'):
        for index, item in enumerate(element, 1):
            p = doc.add_paragraph(style='List Bullet' if tag == 'ul' else 'Normal')
            if tag == 'ol':
                p.paragraph_format.left_indent = Inches(.22)
                p.paragraph_format.first_line_indent = Inches(-.22)
                p.add_run(f'{index}. ')
            inline(item, p)
    elif tag == 'blockquote':
        for child in element:
            p = doc.add_paragraph(style='Quote'); inline(child, p)
    elif tag == 'pre':
        p = doc.add_paragraph(); p.paragraph_format.keep_together = True
        run = p.add_run(''.join(element.itertext()).rstrip())
        run.font.name = 'Consolas'; run.font.size = Pt(9)
        shade = OxmlElement('w:shd'); shade.set(qn('w:fill'), 'F2F4F8'); p._p.get_or_add_pPr().append(shade)
    elif tag == 'table':
        rows = element.xpath('.//tr')
        table = doc.add_table(rows=0, cols=len(rows[0])); table.style = 'Table Grid'
        for idx, row in enumerate(rows):
            cells = table.add_row().cells
            for cell, source in zip(cells, row):
                p = cell.paragraphs[0]; inline(source, p, bold=idx == 0)
                p.paragraph_format.space_after = Pt(4)
                for run in p.runs: run.font.size = Pt(9.5)
                if idx == 0:
                    shade = OxmlElement('w:shd'); shade.set(qn('w:fill'), 'E9EDF7'); cell._tc.get_or_add_tcPr().append(shade)
            if idx == 0: table.rows[0]._tr.get_or_add_trPr().append(OxmlElement('w:tblHeader'))
        doc.add_paragraph().paragraph_format.space_after = Pt(2)
    else: raise ValueError(f'Unsupported block: {tag}')

footer = section.footer.paragraphs[0]
footer.alignment = 2
run = footer.add_run('Week 3 capstone  |  '); run.font.size = Pt(9)
field = OxmlElement('w:fldSimple'); field.set(qn('w:instr'), 'PAGE'); footer._p.append(field)
doc.save(ROOT / 'WEEK_3_DOCUMENTATION.docx')
css = '''body{font-family:Arial,sans-serif;max-width:1000px;margin:40px auto;padding:0 30px;color:#25334b;line-height:1.55}
h1,h2,h3{color:#182b4d;line-height:1.25}h1{font-size:36px}h2{border-top:1px solid #dce2ec;padding-top:24px;margin-top:36px}
table{border-collapse:collapse;width:100%;margin:20px 0;font-size:14px;table-layout:fixed}td,th{border:1px solid #d4dbe7;padding:9px;vertical-align:top;overflow-wrap:anywhere}th{background:#edf0f9;text-align:left}
img{max-width:100%;height:auto}a{color:#5948ad}pre{padding:16px;background:#f3f5f9;white-space:pre-wrap;overflow-wrap:anywhere}code{font-size:.9em}blockquote{border-left:4px solid #6554b8;margin:18px 0;padding:4px 20px;background:#f6f4fc}
@media print{body{max-width:none;margin:0;font-size:10pt}h1,h2,h3{break-after:avoid}img,tr,pre{break-inside:avoid}a{color:inherit}}
'''
(ROOT / 'WEEK_3_DOCUMENTATION.html').write_text('<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Week 3 project documentation</title><style>'+css+'</style></head><body>'+body+'</body></html>')
print('Created Word export and HTML preview.')
