set -e

# This script is meant to make filenames of media (photos, videos, etc.) uniform and sortable
# Always make a backup of the originals before running this script!
#
# The general naming scheme is as follows:
# YYYY-MM-DD_HH-MM-SS.EXT
# 
# There are some special cases:
#  - WhatsApp
#     - It strips metadata for privacy reasons, so we cannot get the EXIF data, so we cannot know
#       the original dates for the piece of media
#     - WhatsApp assigns files names based on when they were sent:
#        - The naming scheme is IMG-YYYYMMDD-WAXXYY.jpg
#        - XXYY is a sequential number based on how many pictures have been received previously
#        - To avoid overwriting files reeceived at the same time, we use YY as if they were seconds
#     - We 
#     - We append "wa_" at the beginning of a file to denote that it came from WhatsApp
#  - Telegram
#     - This one is worse than WhatsApp. Not only does it strip the EXIF data, the 
# Note that this script does not change the casing of extension names

# TODO:
#  - Automate renaming of Telegram files


# Rename WhatsApp files according to their names
for f in ./*; do
	is_img=$(echo $f | head -c 5 | tail -c 3)
	is_wpp=$(echo $f | tail -c 11 | head -c 2)
	if (test $is_img = 'IMG' || test $is_img = 'VID' || test $is_img = 'PTT') && test $is_wpp = 'WA'; then
		year=$(echo $f | head -c 10 | tail -c 4)
		mnth=$(echo $f | head -c 12 | tail -c 2)
		days=$(echo $f | head -c 14 | tail -c 2)
		ext=$(echo $f | cut -d '.' -f 3)
		counter=$(echo $f | tail -c 7 | head -c 2)
		new_path="wa_${year}-${mnth}-${days}_00-00-${counter}.${ext}"
		#echo $counter
		mv $f $new_path
	fi
done

# Uncomment only in case of dire need!
#exiftool -d unk_%Y-%m-%d_%H-%M-%S%%-c.%%e "-filename<FileModifyDate" -r .

# Rename files according to their EXIF data
exiftool -d %Y-%m-%d_%H-%M-%S%%-c.%%e "-filename<CreateDate" -r .


