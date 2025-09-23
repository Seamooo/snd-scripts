import { bundle } from 'luabundle';
import { glob, open, mkdir } from 'node:fs/promises';
import path from 'node:path';

// TODO(seamooo) if repository increases in size such that this script
// is no longer free to run, investigate incremental compilation

const compileScript = async (src:string, dst: string) => {
    const srcDir = path.dirname(src);
    const outDir = path.dirname(dst);
    const bundledLua = bundle(src, { paths: ['src/?.lua', `${srcDir}/?.lua`] });
    await mkdir(outDir, {recursive: true});
    const handle = await open(dst, 'w');
    console.log(`writing to ${dst}`);
    await handle.write(bundledLua);
};

(async () =>{
    for await (const entry of glob('src/**/*.lua')) {
        // skip lib files
        if(path.basename(entry).startsWith("lib")) continue;
        // write to build dir
        const parts = entry.split(path.sep);
        parts[0] = "build";
        const outpath = path.join(...parts);
        compileScript(entry,outpath);
    }
})()
