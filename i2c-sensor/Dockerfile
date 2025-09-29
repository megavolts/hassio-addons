ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache python3 i2c-tools raspberrypi-utils-pinctrl py3-smbus

COPY --chmod=775 ./rootfs/run.sh /
COPY --chmod=775 ./rootfs/i2c-test.py /sensor/

CMD [ "/run.sh" ]