FROM python:3.9-alpine

RUN adduser -D server
WORKDIR /home/server

# Copy requirements first as to not disturb cache for other changes.
COPY requirements.txt .

# Required base dependencies for psycopg2, lxml, and pillow.
RUN apk add -U --no-cache libpq libxslt-dev libxml2-dev jpeg-dev zlib-dev freetype-dev

RUN apk add --virtual .build-deps build-base postgresql-dev && \
  pip3 install -r requirements.txt && \
  pip3 install gunicorn && \
  apk del .build-deps

USER server

# Finally, copy the entire source.
COPY . .

ENV FLASK_APP cam.py
EXPOSE 5000
ENTRYPOINT ["gunicorn", "-b", ":5000", "--access-logfile", "-", "--error-logfile", "-", "cam:app"]
