pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

PopupCard {
    id: root

    required property Item anchorItem
    required property QtObject bar
    property var targetToplevel: null

    readonly property bool isHyprland: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""

    readonly property string targetAddress: {
        const addr = root.targetToplevel?.HyprlandToplevel?.address ?? "";
        return addr ? "address:0x" + addr : "";
    }

    readonly property string targetProcessName: {
        const appId = (root.targetToplevel?.appId ?? "").trim();
        if (!appId) return "";
        return appId.split(".").pop().replace(/'/g, "");
    }

    function hyprDispatch(cmd) {
        Quickshell.execDetached(["hyprctl", "dispatch", cmd]);
    }

    function forceQuit() {
        const proc = root.targetProcessName;
        if (root.isHyprland) {
            root.hyprDispatch("killactive");
        } else if (proc) {
            Quickshell.execDetached(["bash", "-c", "pkill -x '" + proc + "'; sleep 2; pkill -9 -x '" + proc + "'"]);
        }
        root.close();
    }

    contentWidth: Style.space(230)
    contentHeight: menuLayout.implicitHeight

    Column {
        id: menuLayout
        width: parent.width
        spacing: Style.space(3)

        // Header showing app / window info
        Item {
            width: parent.width
            height: Style.space(28)
            visible: root.targetToplevel !== null

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.space(8)
                anchors.rightMargin: Style.space(8)
                spacing: Style.space(6)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.targetToplevel ? (root.targetToplevel.appId || "Window") : "Desktop"
                    color: Util.alpha(Color.popups.text, 0.6)
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.caption
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    width: parent.width
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Color.popups.border
            opacity: 0.5
            visible: root.targetToplevel !== null
        }

        // --- Hyprland Actions ---
        Rectangle {
            id: floatItem
            visible: root.isHyprland && root.targetToplevel !== null
            width: parent.width
            height: Style.space(30)
            radius: Style.cornerRadius
            color: floatMouse.containsMouse ? Style.hoverFillFor(Color.popups.text, Color.accent) : "transparent"

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.space(10)
                anchors.rightMargin: Style.space(10)
                spacing: Style.space(8)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Style.space(18)
                    text: "\uDB81\uDC37"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Toggle Floating"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Style.space(10)
                anchors.verticalCenter: parent.verticalCenter
                text: "F"
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.caption
                color: Util.alpha(Color.popups.text, 0.45)
            }

            MouseArea {
                id: floatMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const target = root.targetAddress ? root.targetAddress : "";
                    root.hyprDispatch("togglefloating " + target);
                    root.close();
                }
            }
        }

        Rectangle {
            id: fsItem
            visible: root.isHyprland && root.targetToplevel !== null
            width: parent.width
            height: Style.space(30)
            radius: Style.cornerRadius
            color: fsMouse.containsMouse ? Style.hoverFillFor(Color.popups.text, Color.accent) : "transparent"

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.space(10)
                anchors.rightMargin: Style.space(10)
                spacing: Style.space(8)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Style.space(18)
                    text: "\uDB80\uDDB4"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Fullscreen"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Style.space(10)
                anchors.verticalCenter: parent.verticalCenter
                text: "S"
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.caption
                color: Util.alpha(Color.popups.text, 0.45)
            }

            MouseArea {
                id: fsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.hyprDispatch("fullscreen 1");
                    root.close();
                }
            }
        }

        Rectangle {
            id: popoutItem
            visible: root.isHyprland && root.targetToplevel !== null
            width: parent.width
            height: Style.space(30)
            radius: Style.cornerRadius
            color: popoutMouse.containsMouse ? Style.hoverFillFor(Color.popups.text, Color.accent) : "transparent"

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.space(10)
                anchors.rightMargin: Style.space(10)
                spacing: Style.space(8)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Style.space(18)
                    text: "󰤱"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Pop Out (Float & Pin)"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Style.space(10)
                anchors.verticalCenter: parent.verticalCenter
                text: "P"
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.caption
                color: Util.alpha(Color.popups.text, 0.45)
            }

            MouseArea {
                id: popoutMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const target = root.targetAddress ? root.targetAddress : "";
                    root.hyprDispatch("togglefloating " + target);
                    root.hyprDispatch("pin " + target);
                    root.close();
                }
            }
        }

        Rectangle {
            id: scratchpadItem
            visible: root.isHyprland && root.targetToplevel !== null
            width: parent.width
            height: Style.space(30)
            radius: Style.cornerRadius
            color: scratchpadMouse.containsMouse ? Style.hoverFillFor(Color.popups.text, Color.accent) : "transparent"

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.space(10)
                anchors.rightMargin: Style.space(10)
                spacing: Style.space(8)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Style.space(18)
                    text: "\uDB80\uDC8D"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Move to Scratchpad"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Style.space(10)
                anchors.verticalCenter: parent.verticalCenter
                text: "D"
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.caption
                color: Util.alpha(Color.popups.text, 0.45)
            }

            MouseArea {
                id: scratchpadMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const target = root.targetAddress ? root.targetAddress : "";
                    root.hyprDispatch("movetoworkspacesilent special:scratchpad," + target);
                    root.close();
                }
            }
        }

        // --- Generic Window Actions ---
        Rectangle {
            id: closeItem
            visible: root.targetToplevel !== null
            width: parent.width
            height: Style.space(30)
            radius: Style.cornerRadius
            color: closeMouse.containsMouse ? Style.hoverFillFor(Color.popups.text, Color.accent) : "transparent"

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.space(10)
                anchors.rightMargin: Style.space(10)
                spacing: Style.space(8)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Style.space(18)
                    text: "󰅖"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Close Window"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Style.space(10)
                anchors.verticalCenter: parent.verticalCenter
                text: "C"
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.caption
                color: Util.alpha(Color.popups.text, 0.45)
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.targetToplevel) root.targetToplevel.close();
                    root.close();
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Color.popups.border
            opacity: 0.5
            visible: root.targetToplevel !== null
        }

        Rectangle {
            id: killItem
            visible: root.targetToplevel !== null
            width: parent.width
            height: Style.space(30)
            radius: Style.cornerRadius
            color: killMouse.containsMouse ? Style.hoverFillFor(Color.urgent, Color.urgent) : "transparent"

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.space(10)
                anchors.rightMargin: Style.space(10)
                spacing: Style.space(8)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Style.space(18)
                    text: "󰅙"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: killMouse.containsMouse ? Color.urgent : Color.popups.text
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Force Quit"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: killMouse.containsMouse ? Color.urgent : Color.popups.text
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Style.space(10)
                anchors.verticalCenter: parent.verticalCenter
                text: "K"
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: Style.font.caption
                color: killMouse.containsMouse ? Color.urgent : Util.alpha(Color.popups.text, 0.45)
            }

            MouseArea {
                id: killMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.forceQuit();
                }
            }
        }

        // --- Desktop State Item (when clicked on desktop) ---
        Rectangle {
            visible: root.targetToplevel === null
            width: parent.width
            height: Style.space(32)
            radius: Style.cornerRadius
            color: "transparent"

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.space(10)
                anchors.rightMargin: Style.space(10)
                spacing: Style.space(8)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰇄"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Color.popups.text
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Empty Desktop"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: Style.font.body
                    color: Util.alpha(Color.popups.text, 0.7)
                }
            }
        }
    }
}
