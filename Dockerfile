FROM huggla/alpine-official:20181017-edge as alpine

RUN mkdir -p /imagefs/bin /imagefs/sbin /imagefs/etc /imagefs/lib /imagefs/sbin /imagefs/usr/bin /imagefs/usr/lib /imagefs/usr/sbin /imagefs/usr/local/bin /imagefs/tmp /imagefs/var/cache /imagefs/run \
 && echo 'root:x:0:0:root:/dev/null:/sbin/nologin' > /etc/passwd \
 && echo 'root:x:0:' > /etc/group \
 && echo 'starter:x:101:101:starter:/dev/null:/sbin/nologin' >> /etc/passwd \
 && echo 'starter:x:101:' >> /etc/group \
 && echo -n 'users:x:112:root,starter' >> /etc/group \
 && chmod g= /etc/passwd /etc/group \
 && cp -a /etc/passwd /etc/group /imagefs/etc/ \
 && cp -a /lib/libz.so* /lib/*musl* /imagefs/lib/ \
 && cp -a /bin/busybox /bin/sh /imagefs/bin/ \
 && cp -a $(find /bin/* -type l | xargs) /imagefs/bin/ \
 && cp -a $(find /sbin/* -type l | xargs) /imagefs/sbin/ \
 && cp -a $(find /usr/bin/* -type l | xargs) /imagefs/usr/bin/ \
 && cp -a $(find /usr/sbin/* -type l | xargs) /imagefs/usr/sbin/ \
 && cd /imagefs/var \
 && ln -sf ../tmp tmp \
 && /imagefs/bin/busybox rm -rf /home /usr /var /root /tmp/* /media /mnt /run /sbin /srv /etc /bin/* || /imagefs/bin/busybox true \
 && /imagefs/bin/busybox cp -a /imagefs/bin/* /bin/ \
 && /imagefs/bin/busybox find /imagefs -type l -exec /imagefs/bin/busybox sh -c 'for x; do [ -e "$x" ] || /imagefs/bin/busybox rm "$x"; done' _ {} + \
 && cd /imagefs \
 && /imagefs/bin/busybox find * ! -type d ! -type c -exec /imagefs/bin/busybox ls -la {} + | /imagefs/bin/busybox awk -F " " '{print $5" "$9}' | /imagefs/bin/busybox sort -u - | /imagefs/bin/busybox gzip -9 > /imagefs/onbuild-exclude.filelist.gz \
 && /imagefs/bin/busybox chmod -R o= /imagefs

FROM scratch as image

COPY --from=alpine /imagefs /

RUN chgrp -R 102 /* \
 && chgrp 112 / /tmp /etc /usr /usr/lib /usr/local \
 && chgrp -R 112 /lib \
 && chgrp 0 /bin /sbin /usr/bin /usr/sbin /etc/passwd /etc/group \
 && chgrp 101 /usr/local/bin
