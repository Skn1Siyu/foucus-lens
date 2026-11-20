import {readdirSync,statSync,mkdirSync,cpSync,rmSync,readFileSync,writeFileSync}from'node:fs';
import {resolve,join,relative}from'node:path';
import {execFileSync}from'node:child_process';
import {createHash}from'node:crypto';
const root=resolve(import.meta.dirname,'..'),out=join(root,'release'),stage=join(out,'source/focus_lens_web');
execFileSync(process.execPath,['scripts/audit-public.mjs'],{cwd:root,stdio:'inherit'});
rmSync(join(out,'source'),{recursive:true,force:true});mkdirSync(stage,{recursive:true});
const ignore=new Set(['.git','node_modules','.tools','dist','release','reports','bin','obj','.DS_Store']);
function copy(from,to){for(const name of readdirSync(from)){if(ignore.has(name)||(from===root&&name==='docs'))continue;const src=join(from,name),dest=join(to,name);if(statSync(src).isDirectory()){mkdirSync(dest,{recursive:true});copy(src,dest);}else{if(name.startsWith('.env')||/\.(dem|dlreview|db|sqlite3?|log|pem|key|pfx|p12)$/i.test(name))throw new Error('Private file in export: '+relative(root,src));cpSync(src,dest);}}}
copy(root,stage);
const target=join(out,`focus-lens-web-${JSON.parse(readFileSync(join(root,'package.json'))).version}-source.zip`);rmSync(target,{force:true});execFileSync('zip',['-qr',target,'focus_lens_web'],{cwd:join(out,'source')});
const hash=createHash('sha256').update(readFileSync(target)).digest('hex');writeFileSync(target+'.sha256',`${hash}  ${target.split('/').at(-1)}\n`);console.log(JSON.stringify({archive:target,bytes:statSync(target).size,sha256:hash}));
