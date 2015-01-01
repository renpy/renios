import xcodeprojer
import shutil
import os
import plistlib

RENIOS = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def replace_name(o, template, replacement, path=()):
    if isinstance(o, dict):
        for k in list(o.keys()):
            o[k] = replace_name(o[k], template, replacement, path + (k,))

        return o

    elif isinstance(o, list):

        new_o = [ ]

        for i, v in enumerate(o):
            new_o.append(replace_name(v, template, replacement, path + (i,)))

        o[:] = new_o

        return o

    elif isinstance(o, basestring):
        return o.replace(template, replacement)

    else:
        raise Exception("Unknown Xcode entry %r at %r." % (o, path))

def load_info_plist(dest):
    """
    Loads the Info.plist dict from `dest`.
    """

    with open(os.path.join(dest, "Info.plist"), "rb") as f:
        return plistlib.readPlist(f)

def save_info_plist(dest, d):
    """
    Saves `d` as the Info.plist in `dest`.
    """

    fn = os.path.join(dest, "Info.plist")

    with open(fn + ".new", "wb") as f:
        return plistlib.writePlist(d, f)

    try:
        os.unlink(fn)
    except:
        pass

    os.rename(fn + ".new", fn)

def create_project(interface, dest):
    """
    Copies the prototype project to `dest`, which must not already exists. Renames the
    Xcode project to `name`.xcodeproj.
    """

    name = os.path.basename(dest)

    if os.path.exists(dest):
        interface.fail("{} already exists. If you would like to create an new project, please move the existing project out of the way.".format(dest))

    prototype = os.path.join(RENIOS, "prototype")

    interface.info("Copying prototype project...")

    shutil.copytree(prototype, dest)

    interface.info("Updating project with new name...")

    # Update the Xcode project.

    def rm(name):
        path = os.path.join(dest, name)
        if os.path.isdir(path):
            shutil.rmtree(path)
        elif os.path.exists(path):
            os.unlink(path)


    rm("base")
    rm("prototype.xcodeproj/project.xcworkspace")
    rm("prototype.xcodeproj/xcuserdata")

    os.rename(os.path.join(dest, "prototype.xcodeproj"), os.path.join(dest, name + ".xcodeproj"))

    pbxproj = os.path.join(dest, name + ".xcodeproj", "project.pbxproj")

    with open(pbxproj, "r") as f:
        root, _parseinfo = xcodeprojer.parse(f.read())

    root = replace_name(root, "prototype", name)

    output = xcodeprojer.unparse(root, format="xcode", projectname=name)

    with open(pbxproj + ".new", "w") as f:
        f.write(output)

    try:
        os.unlink(pbxproj)
    except:
        pass

    os.rename(pbxproj + ".new", pbxproj)

    # Update the Info.plist.
    p = load_info_plist(dest)
    p["CFBundleName"] = unicode(name)
    p["CFBundleDisplayName"] = unicode(name)
    p["CFBundleIdentifier"] = u"com.domain.application-name"
    save_info_plist(dest, p)

    interface.success("Created the Xcode project.")
