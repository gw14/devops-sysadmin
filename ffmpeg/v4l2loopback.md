הנה דוגמה ברורה ופשוטה איך מתקינים **מצלמה וירטואלית (Virtual Camera)** בלינוקס.
אציג שתי שיטות נפוצות:

---

# 📸 שיטה 1: יצירת מצלמה וירטואלית עם **v4l2loopback**

זה הפתרון הנפוץ ביותר. הוא מאפשר ליצור "מצלמת דמה" שכל תוכנה (Zoom, Teams, OBS וכו’) יכולה לקרוא.

### ✔ מה זה v4l2loopback?

מודול לליבה שמייצר device כמו:

```
/dev/video10
```

ואז אפשר להזרים אליו וידאו ממקור אחר — קובץ, OBS, ffmpeg וכו’.

---

## 🔧 התקנה

### **Debian/Ubuntu**

```bash
sudo apt update
sudo apt install v4l2loopback-dkms v4l2loopback-utils
```

### **Fedora**

```bash
sudo dnf install v4l2loopback
```

### **Arch Linux**

```bash
sudo pacman -S v4l2loopback-dkms
```

---

## 🚀 יצירת מצלמה וירטואלית

טעינת המודול:

```bash
sudo modprobe v4l2loopback devices=1 video_nr=10 card_label="VirtualCam" exclusive_caps=1
```

תיווצר מצלמה וירטואלית ב־:

```
/dev/video10
```

---

# 🎥 הזנת וידאו למצלמה הווירטואלית

## דוגמה: הזרמת וידאו דרך **FFmpeg**

```bash
ffmpeg -re -i input.mp4 -vcodec rawvideo -pix_fmt yuv420p \
    -f v4l2 /dev/video10
```

## דוגמה: שימוש עם **OBS → Virtual Camera**

OBS תומך ב־v4l2loopback באופן מובנה:

1. התקן OBS:

   ```bash
   sudo apt install obs-studio
   ```
2. ב־OBS לחץ:
   **Tools → Start Virtual Camera**

OBS יזרים אוטומטית ל־v4l2loopback.

---

# 🧪 בדיקה

בדיקה שכלי המערכת מזהים את המצלמה:

```bash
v4l2-ctl --list-devices
```

בדיקה בעזרת cheese (תצוגה פשוטה):

```bash
sudo apt install cheese
cheese
```

---

# 📦 שיטה 2: Virtual Camera דרך OBS בלבד (בלי FFmpeg)

ב־OBS ≥ 26 קיימת מצלמה וירטואלית מובנית.

### התקנה

```bash
sudo apt install obs-studio v4l2loopback-dkms
```

### הפעלה

ב־OBS:

```
Tools → Start Virtual Camera
```

והמצלמה הווירטואלית תופיע בתוכנות כמו Zoom/Teams כ־ “OBS Virtual Camera”.

---

# רוצה שאכין לך סקריפט אוטומטי?

אני יכול ליצור:

* Script להתקנה + טעינת מודול אוטומטית
* יחידת systemd שמפעילה את המצלמה הווירטואלית אוטומטית
* או מדריך מתאים לדיסטרו שלך

רק תגיד מה אתה צריך.
