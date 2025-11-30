#!/bin/bash
#
# Autor: Rüdiger Wolff
# Date: 4/9/2024
#
# Programm, dass das Update von Nextcloud übernimmt:
#
# Vorhandene Dateien im Ordner /opt/Nextcloud (in von mir geschriebenem Original; 
# jetzt /home/rwolff/AppImages/Nextcloud/):
# 1) Nextcloud.AppImage
# 2) Nextcloud.AppImage.bak
# 3) Nextcloud-3.13.2-x86_64.AppImage (Bsp.)
#  
# Im Ordner /home/rwolff/Descargas existiert bereits die heruntergeladenen Datei:
# 1) Nextcloud-3.13.4-x86_64.AppImage
#

# Deklaration der Variablen:
# path="/opt/Nextcloud"
path="/home/rwolff/AppImages/Nextcloud/"

# Prüfung, ob das Skript als root ausgeführt wird.
if [ $EUID -ne 0 ];then
    echo >&2 "ERROR: Skript muss als root ausgeführt werden."
    exit 1
fi

# >>> Hauptprogramm <<<

cd /home/rwolff/Descargas/

# Auswahl der Datei zur Aktualisierung mithilfe von zenity
filename=$(zenity --file-selection --title="Wähle die Datei zur Aktualisierung von Nextcloud.")
# Prüfung, ob Datei ausgewählt wurde:
case $? in
         0)
                echo "Es wurde die Datei $filename ausgewählt."
		version=$(echo $filename | cut -d- -f2)
		zenity --info --title="Nextcloud Aktualisierung." --text="Nextcloud wird auf Version $version aktualisiert."
		;;
         1)
                echo "Es wurde keine Datei für die Aktualisierung ausgewählt. Abbruch."
		exit 2
		;;
        -1)
                echo "An unexpected error has occurred."
		exit 3
		;;
esac

# Wechsel in den Zielordner
cd $path

# Kopiere die heruntergeladene Nextcloud-Datei in den Zielordner
cp $filename $path

# Backup der Vorgänger-Version (überschreibt frühere Bak-Datei, falls vorhanden)
mv -f Nextcloud.AppImage Nextcloud.AppImage.bak

# Aktualisierung auf neue Version und "Aktivierung"
cp $filename Nextcloud.AppImage
chmod +x Nextcloud.AppImage

echo "Es wurde Nextcloud auf die neue Version $version aktualisiert."

# Löschen der heruntergeladenen Datei aus dem Download-Ordner
rm $filename 

# Löschen der Nextcloud-Vorgängerversion
# Hinweis per zenity-Fensterchen über die Möglichkeit zur Löschung
zenity --info --title="Nextcloud-Vorgängerversion" --text="Im folgenden Dialog die alte Version von Nextcloud auswählen, um diese zu löschen."
oldversion=$(zenity --file-selection --title="Nextcloud-Vorgängerversion löschen.")
case $? in
         0)
                rm $oldversion
		echo "Es wurde die Datei $oldversion gelöscht."
                ;;
         1)
                echo "Es wurde keine Datei gelöscht."
                ;;
        -1)
                echo "An unexpected error has occurred.";;
esac

# Rückwechseln in vorhergehenden Pfad
cd -

# Ende des Skriptes
echo "$(date +"%F %T") Ende der Aktualisierung."

