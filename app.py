from flask import Flask

app = Flask(__name__)

@app.get("/")
def root():
    return "root v3"   # αλλάζω αριθμό για να δούμε ότι ήρθε ο νέος κώδικας

@app.get("/ping")
def ping():
    return "ok"

@app.get("/__routes")
def routes():
    # δείξε όλους τους κανόνες που βλέπει ο Flask
    return "\n".join(sorted(str(r) for r in app.url_map.iter_rules()))

if __name__ == "__main__":
    import os
    port = int(os.environ.get("PORT", "5055"))
    print(">>> BOOT from:", __file__)
    print(">>> Will listen on port", port)
    app.run(host="0.0.0.0", port=port)
