#!/usr/bin/env python

import argparse
import subprocess
import os

#     for build in $builds; do
#       
#       cmd="lipo -create -output $RENIOSDEPROOT/build/$build/lib/$1"
#       
#       for platform in $platforms; do
#         if [ $platform = x86_64 ]; then
#           os=iphonesimulator
#       else
#         os=iphoneos
#       fi
#       
#       cmd="$cmd -arch $platform $RENIOSDEPROOT/build/$os-$platform/$build/lib/$1" 
#     done
#     
#     $cmd
#     
#   done


def getmtime(fn):
    try:
        return os.path.getmtime(fn)
    except:
        return 0
   

def run(deproot, build, lib):
    target = "{}/build/{}/lib/{}".format(deproot, build, lib)
    target_mtime = getmtime(target)
    
    run = False
    
    cmd = [ 
        "lipo", 
        "-create",
        "-output", target
        ] 
    
    platforms = [
        ("x86_64", "iphonesimulator-x86_64"),
        ("armv7", "iphoneos-armv7"),
        ("arm64", "iphoneos-arm64"),
        ]
    
    for arch, platform in platforms:
        fn = "{}/build/{}/{}/lib/{}".format(deproot, platform, build, lib)
        
        if getmtime(fn) >= target_mtime:
            run = True
            
        cmd.extend([
            "-arch", arch,
            fn,
            ])
        
    if not run:
        return
    
    print target, "needs lipo and strip."
    
    subprocess.check_call(cmd)
    
    subprocess.check_call([
        "xcrun",
        "strip",
        "-Sxr",
        target,
        ])

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("deproot")
    args = ap.parse_args()

    libs = [ ]    
    for fn in os.listdir("{}/build/iphoneos-armv7/release/lib".format(args.deproot)):
        if fn.endswith(".a"):
            libs.append(fn)
            
    for lib in libs:
        run(args.deproot, "debug", lib)
        run(args.deproot, "release", lib)
    
if __name__ == "__main__":
    main()
    