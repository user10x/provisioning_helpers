
FROM python:3

LABEL maintainer="nipun.chawla786@gmail.com"
LABEL build_date="2019-09-25"

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt



ENV AWS_ACCESS_KEY_ID=AKIA6BXXHH5WPWOPJRTY
ENV AWS_SECRET_ACCESS_KEY=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
ENV AWS_DEFAULT_REGION=us-east-1

ENTRYPOINT ["/usr/local/bin/aws"]



