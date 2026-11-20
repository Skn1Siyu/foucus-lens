import {readFileSync,readdirSync,statSync,existsSync} from 'node:fs';
import {resolve,join} from 'node:path';
const root=resolve(import.meta.dirname,'..');
const ignored=new Set(['.git','node_modules','.tools','bin','obj','dist','release','reports']);
function list(dir,source=false,prefix='') {return readdirSync(dir).flatMap(n=>{if(source&&(ignored.has(n)||n==='.DS_Store'||(!prefix&&n==='docs')))return [];const p=join(dir,n),r=prefix+n;return statSync(p).isDirectory()?list(p,source,r+'/'):[r];});}
const problems=[],source=list(root,true),site=existsSync(join(root,'dist'))?list(join(root,'dist')):[];
if(!site.length)problems.push('Missing dist build');
const rules=[['local home path',/(?:\/Users\/|[A-Za-z]:\\Users\\)/],['Steam user ID',/7656119[0-9]{10}/],['private key',/-----BEGIN (?:[A-Z]+ )?PRIVATE KEY-----/],['GitHub token',/(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,})/],['AWS access key',/(?:AKIA|ASIA)[A-Z0-9]{16}/]];
for(const [scope,files,dir] of [['source',source,root],['site',site,join(root,'dist')]])for(const f of files){
 if(/(?:^|\/)\.env(?:\.|$)|\.(?:dem|dlreview|db|sqlite3?|pdb|pem|key|pfx|p12|log)$/i.test(f))problems.push(`${scope}: forbidden private file ${f}`);
 // This scanner contains examples of the patterns, not private data.
 if(f==='scripts/audit-public.mjs')continue;
 const content=readFileSync(join(dir,f)).toString('utf8');
 for(const [name,rule]of rules)if(rule.test(content))problems.push(`${scope}: ${name} in ${f}`);
 if(statSync(join(dir,f)).size>95*1024*1024)problems.push(`${scope}: file exceeds safe GitHub size ${f}`);
}
for(const f of ['licenses/index.html','licenses/Focus-Lens-MIT.txt','licenses/demofile-net.txt','licenses/demofile-net-ACKNOWLEDGEMENTS.txt','licenses/npm-runtime-licenses.txt','licenses/manifest.json','licenses/upstream/dotnet-MIT.txt','licenses/upstream/dotnet-THIRD-PARTY-NOTICES.txt','licenses/upstream/Snappier-BSD-3-Clause.txt','licenses/upstream/Google.Protobuf-BSD-3-Clause.txt','licenses/upstream/protobuf-net-Apache-2.0.txt'])if(!existsSync(join(root,'dist',f)))problems.push('Missing distributed notice '+f);
if(problems.length){console.error(problems.join('\n'));process.exit(1);}
console.log(`Public audit passed: ${source.length} source files, ${site.length} site files. Intentional author/QQ credit retained. Pattern scan is not a proof that all possible secrets are absent.`);
