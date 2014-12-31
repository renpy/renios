import xcodeprojer
import shutil
import os
import plistlib

RENIOS = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def find_prototype():

    with open("../prototype/prototype.xcodeproj/project.pbxproj", "r") as f:
        root, parseinfo = xcodeprojer.parse(f.read())

    def dict_path(d, path):
        for k, v in sorted(d.items()):
            p = (path) + (k,)

            if isinstance(v, dict):
                dict_path(v, p)
            elif isinstance(v, unicode):
                if "prototype" in v.lower():
                    print p, v

    dict_path(root, ())

def update_dict(d, path, value):
    """
    Updates a value accessed through a path of keys in a dict.
    """

    for i in path[:-1]:
        d = d[i]

    d[i] = unicode(value)

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
    shutil.rmtree(os.path.join(dest, "base"))
    os.rename(os.path.join(dest, "prototype.xcodeproj"), os.path.join(dest, name + ".xcodeproj"))

    pbxproj = os.path.join(dest, name + ".xcodeproj", "project.pbxproj")

    with open(pbxproj, "r") as f:
        root, _parseinfo = xcodeprojer.parse(f.read())
    update_dict(root, (u'objects', u'E22EF4C41A33491200A74B9F', u'name'), name)
    update_dict(root, (u'objects', u'E22EF4C41A33491200A74B9F', u'productName'), name)
    update_dict(root, (u'objects', u'E22EF4C51A33491200A74B9F', u'path'), name + ".app")
    update_dict(root, (u'objects', u'E22EF4ED1A33491200A74B9F', u'buildSettings', u'PRODUCT_NAME'), name)
    update_dict(root, (u'objects', u'E22EF4EE1A33491200A74B9F', u'buildSettings', u'PRODUCT_NAME'), name)

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


if __name__ == "__main__":
    find_prototype()
