from pathlib import Path
from html import escape
from PIL import Image, ImageDraw, ImageFont
import math

OUT = Path(__file__).parent
NAVY = '#182B4D'
PURPLE = '#6554B8'
MUTED = '#53647D'
LINE = '#7686A2'
PALE = '#F5F3FF'
BLUE = '#F0F5FC'
BORDER = '#C9D4E5'
REGULAR = '/System/Library/Fonts/Supplemental/Arial.ttf'
BOLD = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'


class Canvas:
    def __init__(self, width, height, title, description):
        self.width, self.height = width, height
        self.image = Image.new('RGB', (width, height), 'white')
        self.draw = ImageDraw.Draw(self.image)
        self.svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img" aria-labelledby="title desc">',
                    f'<title id="title">{escape(title)}</title><desc id="desc">{escape(description)}</desc>',
                    f'<rect width="{width}" height="{height}" fill="white"/>']

    def text(self, x, y, value, size=30, color=NAVY, bold=False, anchor='middle'):
        font = ImageFont.truetype(BOLD if bold else REGULAR, size)
        # Both backends use an explicit alphabetic baseline.
        self.draw.text((x, y), value, fill=color, font=font,
                       anchor={'middle': 'ms', 'start': 'ls'}[anchor])
        self.svg.append(f'<text x="{x}" y="{y}" text-anchor="{anchor}" font-family="Arial, Helvetica, sans-serif" font-size="{size}" font-weight="{700 if bold else 400}" fill="{color}">{escape(value)}</text>')

    def box(self, x, y, width, height, title, lines=(), fill=BLUE, accent=NAVY):
        self.draw.rounded_rectangle((x, y, x+width, y+height), radius=18, fill=fill, outline=BORDER, width=2)
        self.svg.append(f'<rect x="{x}" y="{y}" width="{width}" height="{height}" rx="18" fill="{fill}" stroke="{BORDER}" stroke-width="2"/>')
        count = len(lines)
        title_y = y + height / 2 + 11 - count * 19
        self.text(x+width/2, title_y, title, 32, accent, True)
        for i, line in enumerate(lines):
            self.text(x+width/2, title_y+38*(i+1), line, 26, MUTED)

    def arrow(self, points, color=LINE, width=4):
        self.draw.line(points, fill=color, width=width, joint='curve')
        self.svg.append(f'<polyline points="{" ".join(f"{x},{y}" for x,y in points)}" fill="none" stroke="{color}" stroke-width="{width}" stroke-linecap="round" stroke-linejoin="round"/>')
        (ax, ay), (bx, by) = points[-2:]
        theta = math.atan2(by-ay, bx-ax)
        p1 = (bx-16*math.cos(theta-.47), by-16*math.sin(theta-.47))
        p2 = (bx-16*math.cos(theta+.47), by-16*math.sin(theta+.47))
        self.draw.polygon([(bx, by), p1, p2], fill=color)
        self.svg.append(f'<polygon points="{bx},{by} {p1[0]},{p1[1]} {p2[0]},{p2[1]}" fill="{color}"/>')

    def save(self, name):
        self.image.save(OUT / f'{name}.png')
        (OUT / f'{name}.svg').write_text('\n'.join(self.svg + ['</svg>']))


c = Canvas(1600, 1240, 'Current implemented architecture',
           'A single executor uses the notebook host and shared tool runtime to drive the Movies app through Appium and XCUITest. The app uses TMDB. Saved evidence supports HTML, JSON, and video review.')
c.text(80, 82, 'Current implemented architecture', 44, bold=True, anchor='start')
c.text(80, 128, 'Single executor • LLM chooses; host validates and executes; Appium drives', 28, MUTED, anchor='start')
left, wide, mid = 80, 870, 515
nodes = [
    (190, 90, 'Human scenario', (), BLUE, NAVY),
    (330, 140, 'Notebook host', ('create_agent model–tool loop', 'LLM selects the next tool request'), PALE, PURPLE),
    (520, 110, 'Shared tool runtime', ('Host validates and executes tool requests',), PALE, PURPLE),
    (680, 90, 'Appium server', (), BLUE, NAVY),
    (820, 90, 'XCUITest / WebDriverAgent', (), BLUE, NAVY),
    (960, 110, 'Movies iOS app', ('Running on the iOS Simulator',), BLUE, NAVY),
]
for idx, (y, h, title, lines, fill, accent) in enumerate(nodes):
    c.box(left, y, wide, h, title, lines, fill, accent)
    if idx:
        prev = nodes[idx-1]
        c.arrow([(mid, prev[0]+prev[1]), (mid, y)])
c.box(1080, 520, 440, 110, 'Saved evidence', ('UI, screenshots, action logs',), PALE, PURPLE)
c.arrow([(950, 575), (1080, 575)], PURPLE)
c.box(1080, 700, 440, 140, 'Review artifacts', ('HTML + JSON reports', 'Recorded video'), PALE, PURPLE)
c.arrow([(1300, 630), (1300, 700)], PURPLE)
c.box(1080, 960, 440, 110, 'TMDB API', ('Live catalog and metadata',), BLUE, NAVY)
c.arrow([(950, 1015), (1080, 1015)])
c.text(80, 1152, 'The app calls its data provider directly. The testing host operates the visible UI.', 28, MUTED, anchor='start')
c.text(80, 1198, 'Current runtime only; future multi-agent stages are not shown.', 26, MUTED, anchor='start')
c.save('current-implemented-architecture')

c = Canvas(1600, 1290, 'Current observe–act loop',
           'The runtime observes the current UI, captures native XML and PNG, maps semantics and native identity to temporary element references, receives an LLM tool request, revalidates the target and limits, performs an Appium action, and observes again.')
c.text(80, 82, 'Current observe–act loop', 44, bold=True, anchor='start')
c.text(80, 128, 'Each device action is grounded in current UI evidence', 28, MUTED, anchor='start')
left, wide, mid = 140, 1080, 680
steps = [
    ('Observe the current UI', 'Read the active app screen'),
    ('Capture native XML + PNG', 'UI hierarchy plus a screenshot'),
    ('Create temporary element_ref values', 'Host maps semantics and native identity'),
    ('LLM requests a tool action', 'The request names an observed element_ref'),
    ('Host revalidates the target and limits', 'Check identity, current state, and permitted action'),
    ('Appium performs the action', 'Drive the app, then obtain a fresh observation'),
]
for i, (title, detail) in enumerate(steps):
    y = 190 + i*160
    c.box(left, y, wide, 110, title, (detail,), PALE if i in (2,3,4) else BLUE,
          PURPLE if i in (2,3,4) else NAVY)
    if i:
        c.arrow([(mid, y-50), (mid, y)])
c.arrow([(1220, 1045), (1460, 1045), (1460, 245), (1220, 245)], PURPLE)
c.text(1340, 590, 'Observe', 28, PURPLE, True)
c.text(1340, 630, 'again', 28, PURPLE, True)
c.text(80, 1176, 'element_ref is a temporary handle to observed UI, not a permanent app identifier.', 28, MUTED, anchor='start')
c.text(80, 1222, 'The host validates requests; Appium and the native driver execute device actions.', 28, MUTED, anchor='start')
c.save('current-observe-act-loop')

print('Created 1600 × 1240 architecture and 1600 × 1290 observe–act diagrams as SVG + PNG.')
