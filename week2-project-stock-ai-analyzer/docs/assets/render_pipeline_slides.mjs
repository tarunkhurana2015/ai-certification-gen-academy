// Render local SVG artwork to 4K PNGs and per-pipeline / combined slide PDFs.
// Supply --puppeteer-module /path/to/puppeteer.js if Puppeteer is not installed locally.
import {readFile, access} from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

const here=path.dirname(fileURLToPath(import.meta.url));
const option=(name)=>{const i=process.argv.indexOf(name);return i>=0?process.argv[i+1]:undefined;};
const modulePath=option('--puppeteer-module');
const {default:puppeteer}=await import(modulePath?pathToFileURL(path.resolve(modulePath)).href:'puppeteer');
let chrome=option('--chrome');
if(!chrome){
  const macChrome='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
  try{await access(macChrome);chrome=macChrome;}catch{}
}
const groups=JSON.parse(await readFile(path.join(here,'slides.json'),'utf8'));
const browser=await puppeteer.launch({executablePath:chrome,args:['--no-sandbox','--disable-gpu']});
const pages=[];
const failures=[];
try{
  const page=await browser.newPage();
  await page.setViewport({width:1920,height:1080,deviceScaleFactor:2});
  const toPdf=async(slides,destination)=>{
    // Target only the root SVGs; nested technology logos keep their own dimensions.
    await page.setContent('<html><head><style>@page{size:20in 11.25in;margin:0}*{box-sizing:border-box}body{margin:0}section{width:1920px;height:1080px;break-after:page}section:last-child{break-after:auto}section>svg{display:block;width:1920px;height:1080px}</style></head><body>'+slides.map(s=>'<section>'+s+'</section>').join('')+'</body></html>',{waitUntil:'load'});
    await page.evaluate(()=>document.fonts.ready);
    await page.pdf({path:destination,width:'20in',height:'11.25in',preferCSSPageSize:true,printBackground:true,margin:{top:0,right:0,bottom:0,left:0}});
  };
  for(const group of groups){
    const slides=[];
    for(const name of group.slides){
      const svg=await readFile(path.join(here,group.pipeline,name+'.svg'),'utf8');slides.push(svg);pages.push(svg);
      await page.setContent('<html><head><style>body{margin:0;background:#191816}body>svg{display:block}</style></head><body>'+svg+'</body></html>',{waitUntil:'load'});
      await page.evaluate(()=>document.fonts.ready);
      const overflow=await page.evaluate(()=>{
        const errors=[];
        for(const t of document.querySelectorAll('text')){
          const b=t.getBBox();if(b.x<0||b.x+b.width>1910||b.y<0||b.y+b.height>1078)errors.push({text:t.textContent,reason:'outside slide'});
        }
        for(const r of document.querySelectorAll('rect[data-card]')){
          const x=+r.getAttribute('x'),y=+r.getAttribute('y'),w=+r.getAttribute('width'),h=+r.getAttribute('height');
          for(const t of document.querySelectorAll('text')){
            const tx=+t.getAttribute('x'),ty=+t.getAttribute('y');
            if(tx>x&&tx<x+w&&ty>y+60&&ty<y+h){
              const b=t.getBBox();if(b.x+b.width>x+w-16||b.y+b.height>y+h-10)errors.push({text:t.textContent,reason:'outside card',card:r.getAttribute('data-card')});
            }
          }
        }
        return errors;
      });
      console.log(name+' label overflow: '+JSON.stringify(overflow));
      if(overflow.length)failures.push({name,overflow});
      await page.screenshot({path:path.join(here,group.pipeline,name+'.png')});
    }
    if(!group.combined_only)await toPdf(slides,path.join(here,group.pipeline,group.pipeline+'-slides.pdf'));
  }
  await toPdf(pages,path.join(here,'rag-pipeline-slides.pdf'));
  if(failures.length)throw new Error('Label overflow detected; review the rendered previews.');
  console.log(`PASS: ${pages.length} slide previews at 3840×2160; ${groups.filter(g=>!g.combined_only).length} pipeline PDFs and the combined ${pages.length}-page PDF.`);
}finally{await browser.close();}
