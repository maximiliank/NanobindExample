FROM node:current

RUN set -ex; \
    curl -s https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee /usr/share/keyrings/google.gpg >/dev/null; \
    echo "deb [signed-by=/usr/share/keyrings/google.gpg] https://dl.google.com/linux/chrome/deb stable main" > /etc/apt/sources.list.d/chrome.list; \
    apt-get clean; \
    apt-get update; \
    apt-get upgrade -y --no-install-recommends; \
    apt-get install -y --no-install-recommends google-chrome-stable; \
    rm -r /var/lib/apt/lists/*;

RUN set -ex; \
    mkdir -p /opt/npm_packages; \
    cd /; \
    PUPPETEER_SKIP_DOWNLOAD='true' npm install --verbose --prefix /opt/npm_packages decktape reveal.js katex mathjax;

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome
ENV PATH="/opt/npm_packages/node_modules/.bin${PATH:+:${PATH}}"

ENTRYPOINT ["decktape", "--chrome-arg=--no-sandbox"]

CMD ["-h"]