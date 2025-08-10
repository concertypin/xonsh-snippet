#!/usr/bin/env xonsh

"""
  __________________
< Yay this is cowsay >
  ------------------
         \   ^__^
          \  (oo)\_______
             (__)\       )\/\\
                 ||----w |
                 ||     ||

  ____________________________________
/ It can be used for rcfile to disturb \\
\\ concentration                        /
  ------------------------------------
         \   ^__^
          \  (oo)\_______
             (__)\       )\/\\
                 ||----w |
                 ||     ||
  _______________________________________
/ Usage is `cowsay somewhat text`, simple \\
\\ enough. It supports local caching.      /
  ---------------------------------------
         \   ^__^
          \  (oo)\_______
             (__)\       )\/\\
                 ||----w |
                 ||     ||
"""
def __aliases_cowsay__(argv):
    if(len(argv)==0):
        return __aliases_cowsay__(["No text? Hmm."])
    import hashlib
    import random
    import os
    text=" ".join(argv)
    filename=hashlib.sha256(text.encode()).hexdigest()
    fullpath=f"/var/cache/cowsay/{filename}.txt"
    if os.path.isfile(fullpath):
        cache=open(fullpath,"r")
        print(cache.read())
        cache.close()
        return 0
    else:
        import requests
        import json
        r=requests.get("https://cowsay.morecode.org/say", data={"message":text,"format":"text"})
        print(r.text)
        with open(fullpath,"w") as f:
                f.write(r.text)
        return r.status_code-200
aliases["cowsay"]=__aliases_cowsay__