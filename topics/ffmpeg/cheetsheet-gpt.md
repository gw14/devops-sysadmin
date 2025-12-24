מעולה! הנה לך **טבלת Cheat Sheet מקיפה ל-FFmpeg**, עם כל הפקודות הכי שימושיות ודוגמאות מעשיות – מסודרת לפי קטגוריות כך שתוכל להשתמש בה כ-reference יומיומי.

---

# **FFmpeg Cheat Sheet – פקודות שימושיות ודוגמאות**

| קטגוריה                     | פקודה / פרמטר                    | הסבר                       | דוגמה                                                                                              |
| --------------------------- | -------------------------------- | -------------------------- | -------------------------------------------------------------------------------------------------- |
| **מידע על קובץ**            | `ffprobe file`                   | מציג מידע מלא על הקובץ     | `ffprobe input.mp4`                                                                                |
| **המרת פורמטים**            | `ffmpeg -i input.ext output.ext` | המרה בין פורמטים שונים     | `ffmpeg -i video.mov video.mp4`                                                                    |
| **שינוי Codec**             | `-c:v codec` / `-c:a codec`      | שינוי codec וידאו או אודיו | `ffmpeg -i input.mp4 -c:v libx264 -c:a aac output.mp4`                                             |
| **חיתוך וידאו**             | `-ss start -to end -c copy`      | חיתוך וידאו ללא קידוד מחדש | `ffmpeg -ss 00:01:00 -to 00:02:30 -i input.mp4 -c copy cut.mp4`                                    |
| **חיתוך אודיו**             | `-ss start -to end -c copy`      | חיתוך אודיו                | `ffmpeg -ss 00:00:30 -to 00:01:30 -i input.mp3 -c copy cut.mp3`                                    |
| **חילוץ אודיו**             | `-q:a 0 -map a`                  | חילוץ אודיו מקובץ וידאו    | `ffmpeg -i input.mp4 -q:a 0 -map a output.mp3`                                                     |
| **מיזוג קבצים**             | `concat`                         | מיזוג קבצים בלי קידוד מחדש | `ffmpeg -f concat -safe 0 -i file_list.txt -c copy output.mp4`                                     |
| **שינוי רזולוציה**          | `-vf scale=w:h`                  | שינוי רזולוציה של וידאו    | `ffmpeg -i input.mp4 -vf scale=1280:720 output.mp4`                                                |
| **שינוי Frame Rate**        | `-r fps`                         | שינוי קצב פריימים          | `ffmpeg -i input.mp4 -r 60 output.mp4`                                                             |
| **הוספת טקסט / Watermark**  | `-vf "drawtext=...`              | הוספת טקסט על הוידאו       | `ffmpeg -i input.mp4 -vf "drawtext=text='Hello':x=10:y=10:fontsize=24:fontcolor=white" output.mp4` |
| **הפיכת וידאו ל-GIF**       | `-vf fps=fps,scale=w:h`          | יצירת GIF                  | `ffmpeg -i input.mp4 -vf "fps=10,scale=320:-1" output.gif`                                         |
| **שינוי אודיו Mono/Stereo** | `-ac 1` / `-ac 2`                | שינוי ערוצי אודיו          | `ffmpeg -i input.mp3 -ac 1 output_mono.mp3`                                                        |
| **אוטומציה עם תיקיות**      | Bash/PowerShell loop             | המרת כל קובץ בתיקייה       | `for f in *.mov; do ffmpeg -i "$f" "${f%.mov}.mp4"; done`                                          |
| **לוגים ושגיאות**           | `-loglevel level`                | בדיקה של שגיאות והודעות    | `ffmpeg -i input.mp4 -loglevel debug output.mp4`                                                   |
| **שמירה על איכות מקורית**   | `-c copy`                        | העתקה ישירה ללא קידוד מחדש | `ffmpeg -i input.mp4 -c copy output.mp4`                                                           |

---

💡 **טיפים שימושיים:**

1. תמיד לעבוד על **עותק של הקובץ**, לא על המקור.
2. `ffmpeg -h` נותן את כל האופציות הבסיסיות.
3. `-y` מאפשר לכתוב על קובץ קיים ללא הודעה.
4. ניתן לשלב **מספר פילטרים** עם `-vf "filter1,filter2"` או `-af "filter1,filter2"`.
5. שמור **קובץ טקסט עם פקודות שימושיות** שלך – Cheat Sheet אישי משתלם מאוד.

---
