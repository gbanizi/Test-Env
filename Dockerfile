FROM ubuntu:22.04
WORKDIR /app
RUN apt-get update && apt-get install -y bash
COPY payments.log .
COPY monitor.sh .
RUN chmod +x monitor.sh
CMD ["./monitor.sh"]
