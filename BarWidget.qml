import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
    id: root
    moduleName: "iamcheyan.active-window"

    property int titleAreaWidth: Number(setting("maxWidth", 280))

    // Compositor-agnostic focused-window lookup
    readonly property var focusedToplevel: {
        const barScreen = root.bar?.screen?.name ?? root.QsWindow.window?.screen?.name ?? "";
        const list = ToplevelManager.toplevels.values;
        const matches = list.filter(t => t.activated && (barScreen === "" || t.screens.some(s => s.name === barScreen)));
        return matches[0] ?? ToplevelManager.activeToplevel ?? null;
    }

    readonly property bool hasWindow: root.focusedToplevel !== null &&
        Boolean((root.focusedToplevel.title && root.focusedToplevel.title.length > 0) ||
                (root.focusedToplevel.appId && root.focusedToplevel.appId.length > 0))

    readonly property string windowTitle: root.focusedToplevel?.title ?? ""
    readonly property string windowAppId: root.focusedToplevel?.appId ?? ""

    readonly property string displayTitle: root.hasWindow
        ? (root.windowTitle || root.windowAppId)
        : root.desktopDisplayName()

    readonly property string displayIcon: root.hasWindow
        ? root.resolveAppIcon(root.windowAppId)
        : root.osIconPath

    // --- Distro & System Release Detection ---
    property string distroName: "Linux"
    property string distroId: "nixos"
    property string distroVersion: ""
    property string distroLike: ""

    FileView {
        id: osReleaseFile
        path: "/etc/os-release"
        onLoaded: root.parseOsRelease(osReleaseFile.text())
    }

    Component.onCompleted: {
        if (osReleaseFile.text()) {
            root.parseOsRelease(osReleaseFile.text());
        }
    }

    function parseOsRelease(text) {
        if (!text) return;
        const prettyMatch = text.match(/^PRETTY_NAME="?(.+?)"?$/m);
        const nameMatch = text.match(/^NAME="?(.+?)"?$/m);
        root.distroName = prettyMatch ? prettyMatch[1] : (nameMatch ? nameMatch[1].replace(/Linux/i, "").trim() : "Linux");

        const verMatch = text.match(/^VERSION_ID="?(.+?)"?$/m);
        root.distroVersion = verMatch ? verMatch[1] : "";

        const idMatch = text.match(/^ID="?(.+?)"?$/m);
        root.distroId = idMatch ? idMatch[1] : "";

        const likeMatch = text.match(/^ID_LIKE="?(.+?)"?$/m);
        root.distroLike = likeMatch ? likeMatch[1] : "";
    }

    function desktopDisplayName() {
        var name = root.distroName;
        if (!name || name.length === 0) return "Desktop";
        name = name.replace(/\s*\([^)]*\)\s*$/, "").trim();
        var ver = root.distroVersion;
        if (ver && ver.length > 0 && !name.includes(ver)) {
            name += " " + ver;
        }
        return name || "Desktop";
    }

    function osIconName() {
        const id = (root.distroId || "").toLowerCase();
        const like = (root.distroLike || "").toLowerCase();
        const name = (root.distroName || "").toLowerCase();

        const idMap = {
            "fedora": "fedora",
            "arch": "arch",
            "artix": "arch",
            "cachyos": "arch",
            "ubuntu": "ubuntu",
            "debian": "debian",
            "raspbian": "debian",
            "kali": "debian",
            "linuxmint": "mint",
            "endeavouros": "endeavouros",
            "nixos": "nixos",
            "manjaro": "manjaro",
            "opensuse": "opensuse",
            "suse": "opensuse",
            "popos": "pop-os",
            "zorin": "zorin-os",
            "centos": "centos",
            "redhat": "redhat",
            "rocky": "rockylinux",
            "alpine": "alpine",
            "gentoo": "gentoo",
            "funtoo": "gentoo",
        };
        if (id in idMap) return idMap[id];

        const likeMap = {
            "fedora": "fedora",
            "arch": "arch",
            "debian": "debian",
            "ubuntu": "ubuntu",
            "rhel": "redhat",
            "centos": "centos",
            "alpine": "alpine",
            "gentoo": "gentoo",
        };
        const likes = like.split(/\s+/);
        for (let i = 0; i < likes.length; i++) {
            if (likes[i] in likeMap) return likeMap[likes[i]];
        }

        if (name.includes("endeavouros")) return "endeavouros";
        if (name.includes("nixos")) return "nixos";
        if (name.includes("opensuse")) return "opensuse";
        if (name.includes("manjaro")) return "manjaro";
        if (name.includes("zorin")) return "zorin-os";
        if (name.includes("rocky linux")) return "rockylinux";
        if (name.includes("centos")) return "centos";
        if (name.includes("red hat")) return "redhat";
        if (name.includes("alpine")) return "alpine";
        if (name.includes("gentoo")) return "gentoo";
        if (name.includes("mint")) return "mint";
        if (name.includes("pop")) return "pop-os";
        if (name.includes("ubuntu")) return "ubuntu";
        if (name.includes("debian")) return "debian";
        if (name.includes("arch")) return "arch";
        if (name.includes("fedora")) return "fedora";

        return "fedora";
    }

    readonly property string osIconPath: Qt.resolvedUrl("icons/" + root.osIconName() + ".svg")

    function resolveAppIcon(appId) {
        if (!appId || appId.length === 0) return "";
        var icon = Quickshell.iconPath(appId, true);
        if (icon) return icon;
        icon = Quickshell.iconPath(appId.toLowerCase(), true);
        if (icon) return icon;
        var parts = appId.split(".");
        var last = parts[parts.length - 1].toLowerCase();
        icon = Quickshell.iconPath(last, true);
        if (icon) return icon;
        return "";
    }

    function fallbackLetter(appId, title) {
        const source = (appId && appId.length > 0) ? appId : (title ?? "");
        if (!source || source.length === 0) return "?";
        return source.charAt(0).toUpperCase();
    }

    visible: !root.vertical
    implicitHeight: root.barSize
    implicitWidth: Math.min(root.titleAreaWidth, Style.space(8) * 2 + 16 + Style.space(6) + titleText.implicitWidth)

    Behavior on implicitWidth {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    Row {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: Style.space(8)
        anchors.rightMargin: Style.space(8)
        spacing: Style.space(6)

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: 14

            Image {
                id: iconImage
                anchors.fill: parent
                source: root.displayIcon
                sourceSize.width: 14 * Screen.devicePixelRatio
                sourceSize.height: 14 * Screen.devicePixelRatio
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: source !== "" && status !== Image.Error
                smooth: true
            }

            Rectangle {
                anchors.fill: parent
                visible: !iconImage.visible || iconImage.status === Image.Error
                radius: 3
                color: Util.alpha(root.bar ? root.bar.barForeground : Color.foreground, 0.15)

                Text {
                    anchors.centerIn: parent
                    text: root.fallbackLetter(root.windowAppId, root.displayTitle)
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: 9
                    font.bold: true
                    color: root.bar ? root.bar.barForeground : Color.foreground
                }
            }
        }

        Text {
            id: titleText
            textFormat: Text.PlainText
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(root.titleAreaWidth - Style.space(8) * 2 - 14 - Style.space(6), implicitWidth)
            text: root.displayTitle
            color: root.bar ? root.bar.barForeground : Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            opacity: root.hasWindow ? 0.95 : 0.80
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.ArrowCursor

        onEntered: {
            if (root.bar) root.bar.showTooltip(root, root.displayTitle);
        }
        onExited: {
            if (root.bar) root.bar.hideTooltip(root);
        }
    }
}
