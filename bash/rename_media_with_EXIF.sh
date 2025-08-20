set -e

####################################################################################################
#
#
# This script is meant to make filenames of media (photos, videos, etc.) uniform and sortable
#
# IMPORTANT: Always make a backup of the originals before running this script!
#
# The general naming scheme is as follows:
# YYYY-MM-DD_HH-MM-SS.EXT
# An example:
# 2025-08-20_14-19-34.jpg
# 
# There are several prefixes that can be attaches to filenames
#  - wa
#     - Denotes that a file comes from WhatsApp
#     - The date shown is when the file was sent, not the date it was taken
#  - tg
#     - Denotes that a file comes from Telegram
#     - The date shown is when this instance of the file was downloaded, not the date it was taken
#  - unk
#     - Denotes that the file has no metadata and that it cannot be inferred from its filename
#     - The origin of the file cannot be ascertained, so the 'wa' or 'tg' suffixes cannot be used
#     - The date shown is the file modification date ('FileModifyDate' on exiftool)
#  - old
#     - Denotes that the original media is old and is probably a scan or a photo of a physical item
#     - This means the date shown should not be taken as authoritative by any means
#     - Rarely used
#        - Most photos use either the metadata of the 
#
# Note that this script does not change the casing of extension names
#
#
####################################################################################################
#
#
# There are some special cases for media that I've come across so far
# You can read about them and some considerations I've made down below
#
#
####  WhatsApp
#
#  - WhatsApp strips metadata for privacy reasons
#     - This means we cannot get the EXIF data of the original piece of media
#     - We cannot know for certain the original dates for the piece of media
#  - We append 'wa_' at the beginning of a file to denote that it came from WhatsApp
#  - Naming scheme
#     - WhatsApp assigns files names based on when they were sent:
#     - The naming scheme is TTT-YYYYMMDD-WAXXYY.EXT
#        - Example: IMG-20250820-WA0123.mov
#        - XXYY is a sequential number based on how many pictures have been received previously
#        - TTT is an identifier for the type of media (IMG, MOV, etc.)
#  - Renaming considerations
#     - To avoid overwriting files reeceived at the same time, we use YY as if they were seconds
#        - This might lead to files having more than 60 seconds in their names
#     - We are assuming that extension names are three characters long
#        - Automated renaming won't work for extensions that are either shorter or longer
#        - A specific case that pops up are opus files, used for voice notes since 2016
#     - We are assuming that the following are the only types of media that can appear at the
#       beginning of a filename:
#        - IMG denotes images
#        - MOV denotes videos
#        - PTT denotes voice notes
#  - Example:
#     - Original filename: IMG-20250820-WA0123.mov
#     - New filename: wa_2025-08-20_00-00-23.mov
#
#
####  Telegram
#
#  - Telegram is worse than WhatsApp in terms of metadata sutainability
#     - They strip EXIF data for privacy reasons
#     - Filenames rarely reflect any information about the date or time the file was sent
#     - Filenames are often mangled and do not provide any information about the origin of the file
#        - That is, it might be impossible to determine whether a file came from Telegtram or not
#  - We append a 'tg_' at the beginning of a file to denote that it came from Telegram
#  - Naming scheme
#     - TODO
#
#
####  iOS
#
# - TODO
#
#
####  Files of Unknown Origin
#
# - TODO
#
#
####  Old Media
#
# - TODO
#
#
####################################################################################################
#
#
# TODO:
#  - Automate renaming of Telegram files
#  - Fix WhatsApp files going over the 60 second limit
#  - Go back and add the 'old' label to really old pics
#     - Old defined as pics from before 2015 that were not taken by me or shared almost immediately
#
#
####################################################################################################


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


