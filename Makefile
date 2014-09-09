NAME=backup
DESTDIR=
PREFIX=
BIN_DIR=/usr/bin
CONF_DIR=/etc/default
SYSTEMD_UNIT_DIR=/etc/systemd/system
CRON_DIR=/etc/cron.d
LOG_DIR=/var/log
_ROOT=$(DESTDIR)$(PREFIX)

install-script-only: src/backup.sh
	install -D -m 700 src/backup.sh '$(_ROOT)$(BIN_DIR)/$(NAME)'

uninstall-script-only:
	rm -f '$(_ROOT)$(BIN_DIR)/$(NAME)'


install-systemd-config: systemd/backup@.service systemd/backup@.timer
	install -D -m 600 src/example.conf '$(_ROOT)$(CONF_DIR)/$(NAME)@example'

uninstall-systemd-config:
	rm -f '$(_ROOT)$(CONF_DIR)/$(NAME)@example'


install-systemd: install-script-only install-systemd-config src/example.conf
	install -D systemd/backup@.service '$(_ROOT)$(SYSTEMD_UNIT_DIR)/$(NAME)@.service'
	install -D systemd/backup@.timer '$(_ROOT)$(SYSTEMD_UNIT_DIR)/$(NAME)@.timer'
	sed \
		-e 's:/etc/default/backup:$(PREFIX)$(CONF_DIR)/$(NAME):' \
		-e 's:/usr/bin/backup:$(PREFIX)$(BIN_DIR)/$(NAME):' \
		-i '$(_ROOT)$(SYSTEMD_UNIT_DIR)/$(NAME)@.service'

uninstall-systemd: uninstall-script-only uninstall-systemd-config
	rm -f '$(_ROOT)$(SYSTEMD_UNIT_DIR)/$(NAME)@.service'
	rm -f '$(_ROOT)$(SYSTEMD_UNIT_DIR)/$(NAME)@.timer'


install-cron-config: src/example.conf
	install -D -m 600 src/example.conf '$(_ROOT)$(CONF_DIR)/$(NAME)'
	sed -e 's:^\(#\?\s*\)\([a-z]\+=\):\1export \2:i' -i '$(_ROOT)$(CONF_DIR)/$(NAME)'

uninstall-cron-config:
	rm -f '$(_ROOT)$(CONF_DIR)/$(NAME)'


install-cron: install-script-only install-cron-config cron/backup.crontab
	install -D cron/backup.crontab '$(_ROOT)$(CRON_DIR)/$(NAME)'
	install -d '$(_ROOT)$(LOG_DIR)'
	sed \
		-e 's:/etc/default/backup:$(PREFIX)$(CONF_DIR)/$(NAME):' \
		-e 's:/usr/bin/backup:$(PREFIX)$(BIN_DIR)/$(NAME):' \
		-e 's:/var/log/backup.log:$(PREFIX)$(LOG_DIR)/$(NAME).log:' \
		-i '$(_ROOT)$(CRON_DIR)/$(NAME)'

uninstall-cron: uninstall-script-only uninstall-cron-config
	rm -f '$(_ROOT)$(CRON_DIR)/$(NAME)'
	rm -f '$(_ROOT)$(LOG_DIR)/$(NAME).log'


install: install-cron install-systemd
	@echo
	@echo Warning: installed both systemd timer file and crontab file. 1>&2

uninstall: uninstall-cron uninstall-systemd
