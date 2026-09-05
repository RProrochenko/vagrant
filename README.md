# Vagrant lab: Ubuntu 26.04 та Rocky Linux 10

Проєкт створює локальні Vagrant box для VirtualBox і запускає одну або кілька VM.
Шаблони ОС та динамічні налаштування VM зберігаються окремо.

## Вимоги

- Oracle VirtualBox;
- HashiCorp Vagrant;
- HashiCorp Packer — лише для побудови box.

## Конфігурація

Статичні шаблони ОС:

- `config/os/ubuntu26.json` — guest OS, communicator, ISO, checksum і розмір диска Ubuntu;
- `config/os/rocky10.json` — guest OS, communicator, ISO, checksum і розмір диска Rocky.

Динамічні конфігурації, один файл на VM:

- `config/machines/ubuntu26.json` — VM `ubuntu26` на Ubuntu;
- `config/machines/rocky10.json` — VM `rocky` на Rocky.

Кожна конфігурація VM містить усі змінні параметри: `name`, `hostname`, `ssh`,
ресурси box і build, `autostart`, `primary`, `synced_folder` та `provision`.
`ssh.username`, шляхи до ключів і `insert_key` застосовуються одночасно до
Packer, installer та Vagrant. У `provision.packages` задано додаткові пакети,
а `provision.install_docker` керує встановленням Docker. Щоб додати VM,
скопіюй файл із `config/machines/`, задай унікальні `name` і `hostname`,
а в `os` вкажи наявний шаблон ОС.

Стандартна VM — `ubuntu26` з Ubuntu, 4 CPU та 8192 MiB RAM. Щоб застосувати
нові CPU/RAM до вже створеної VM, виконай `vagrant reload ubuntu26`.

Rocky VM уже описана у `config/machines/rocky10.json`, але має `autostart: false`.
Щоб запустити її після побудови та імпорту box:

```powershell
vagrant up rocky --provider virtualbox
```

Для Rocky `synced_folder` вимкнено, оскільки його власний box не встановлює
VirtualBox Guest Additions. Для Ubuntu спільна тека `/vagrant` увімкнена.

Явні `cpus` і `memory` у конкретній VM мають пріоритет над значеннями box.
Поле `primary: true` дозволене лише для однієї VM.

Ресурси `build.resources` належать лише Packer. Вони не впливають на VM після
`vagrant up`: типово build використовує 2 CPU / 4096 MiB, тоді як Ubuntu VM —
4 CPU / 8192 MiB. Це дає змогу збирати box без зайвого навантаження на хост.

## Запуск VM

```powershell
vagrant validate
vagrant up ubuntu26 --provider virtualbox
vagrant ssh ubuntu26
vagrant status
```

Усі VM мають `autostart: false`, тому завжди вказуй їхні ідентифікатори:
`vagrant up ubuntu26` або `vagrant up rocky`.

## Побудова box

`ubuntu26.pkr.hcl` генерує Ubuntu autoinstall із `http/user-data.pkrtpl.hcl`.
`rocky10.pkr.hcl` генерує Kickstart із `http/rocky/rocky.ks.pkrtpl.hcl`.
`build.ps1` спочатку пропонує вибрати VM-конфіг, а потім автоматично вибирає
Packer-шаблон за полем `os`. Шаблон бере статичні параметри з `config/os/` та
динамічні — з обраного файлу в `config/machines/`.
`plugins.pkr.hcl` фіксує Packer 1.16.0, VirtualBox plugin 1.1.5 і Vagrant plugin
1.1.7. Не змінюй ці версії без окремого тестування збірок.

```powershell
.\build.ps1
```

Скрипт показує доступні VM, виконує `packer init`, `packer validate` та
`packer build -force`. Він лише створює `.box` у `builds/` і не імпортує його
у Vagrant. Enter або `0` скасовують вибір без запуску збірки.

Можна запускати скрипт за повним шляхом. Якщо локальна Execution Policy блокує
запуск, використай:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
```

## SSH

Параметри SSH задані в кожному файлі `config/machines/*.json`: `username`,
`private_key_path`, `public_key_path` і `insert_key`. Packer підставляє username
та public key у installer-шаблон під час build, тому після заміни ключа достатньо
змінити шлях у VM-конфігу й перебудувати відповідний box.

## Обмеження

- Vagrant box має відповідати provider `virtualbox` та архітектурі хоста.
- Оновлення box не змінює вже створені VM; протестуй новий box окремо перед
  заміною робочого середовища.
- ISO, checksum і Packer plugins завантажуються під час build, тому потрібен
  доступ до інтернету.
- Ubuntu ISO перевіряється за зафіксованим SHA-256. Для Rocky використовується
  checksum-файл, прив'язаний до конкретного ISO, а не загальний `CHECKSUM`.

## Документація

- [Vagrant multi-machine](https://developer.hashicorp.com/vagrant/docs/multi-machine)
- [Packer VirtualBox ISO builder](https://developer.hashicorp.com/packer/integrations/hashicorp/virtualbox/latest/components/builder/iso)
- [Rocky Linux Kickstart](https://docs.rockylinux.org/guides/automation/kickstart/)
