## Refal9
 Этот ветка представляет собой попытку портирования замечательного проекта Refal-05 в **BSD системы и Plan9Front
 * Все авторские права принадлежат А.Коновалову (Mazdaywik/Refal-05)
 Мне принадлежат следующие права - право на ошибку: программную, грамматическую или смысловую. Откуда вытекает два правила:
 Положительные моменты, благодарности, евро, рубли и биткоины отправляйте автору. Замечания, флейм в /dev/null Ж)

# Компилятор Рефала-05
## О языке и компиляторе 

**Рефал-05** — минималистичный самоприменимый компилятор минималистичного
диалекта Рефала, имеющий общее подмножество с классическим Рефалом-5.
На этом подмножестве он и написан.

Ставились две цели разработки:

* Компилятор должен быть минималистичным и самоприменимым. Т.е. с одной
  стороны, в нём должно быть достаточно выразительных возможностей для
  написания компилятора _(самоприменение)._ С другой — он должен быть
  максимально легковесным _(минимализм)._
* Компилятор должен быть совместим с Рефалом-5, в частности, мог им
  раскручиваться. Это не значит, что он является точным подмножеством,
  это значит, что можно писать программы, которые одинаково работают
  на Рефале-5 и Рефале-05. И это общее подмножество достаточно выразимо
  для написания компилятора.

Удалось достичь объёма исходного кода примерно в 6000 строк, включая исходники
компилятора, библиотеки встроенных функций, рантайма и скриптов сборки.
И, по мнению автора, это минимум. Формально код можно уменьшить, сократив
имена переменных и функций, но это пагубно сказалось бы на стиле исходного
кода, ведь подразумеваемой целью были также _понятные и прозрачные исходники._

Также целью было сделать не игрушку, вещь в себе, которая может _только_
самоприменяться, но и сохранить возможности практического инструмента. Об этом
в разделе **«Установка и использование».**

Разработка велась на основе старой версии Простого Рефала путём как отсечения
избыточных возможностей, так и путём подгонки синтаксиса к Рефалу-5. Поэтому
архитектурно и идейно он наследует Простой Рефал. Причём даже, по духу и идее
он близок к Простому Рефалу версии 001, только при этом совместим с Рефалом-5
и в исходниках существенно меньше говнокода.

### Особенности языка:

* Синтаксис напоминает базисное подмножество Рефала-5: фигурные скобки,
  имена переменных с точками, предложения только из образца и результата.
* Однако, есть важное отличие: все символы-слова должны быть именами
  функций в текущей области видимости.
* Функции можно вызывать косвенно: `<s.Func e.Arg>`.
* Допустимы пустые функции без предложений — их вызов при любом аргументе
  приводит к ошибке отождествления. Пустые функции создаются только ради
  их имён.
* Синтаксический сахар для объявления пустых функций — ключевые слова
  `$ENUM` (локальная) и `$EENUM` (entry):
  ```
  $EENUM FloatType, IntegerType, CharType, StringType;
  ```
* Псевдокомментарии — если комментарий начинается на `*$СЛОВО` и `СЛОВО`
  является корректным ключевым словом, то текст комментария считается
  кодом на Рефале (в конце строки неявная `;`). Предыдущую строку можно
  записать как
  ```
  *$EENUM FloatType, IntegerType, CharType, StringType
  ```
  Т.е. этот «комментарий» определит четыре пустые функции.
* В целях упрощения поддерживается только беззнаковая арифметика ограниченной
  разрядности (зависит от реализации) — как во встроенных арифметических
  функциях, так и в лексическом разборе. Это значит, что на очень длинные
  числа не будет выдано ошибки компиляции — оно будет проинтерпретировано
  как данное число по модулю размера машинного слова.
* Интерфейс с языком Си (чистый C89), вставки кода на Си в программах
  на Рефале. Это сделано для упрощения разработки библиотеки встроенных
  функций.

### Особенности текущей реализации:

* Компиляция осуществляется в язык ANSI/ISO C89, это значит, что для сборки
  компиляции программ требуется компилятор языка Си.
* Размер символов-чисел равен размеру `unsigned long int` для используемого
  компилятора.
* Поддерживается 28 встроенных функций Рефала-5:
  * арифметика: `Add`, `Compare`, `Div`, `Mod`, `Mul`, `Sub` — как уже
    сказано, беззнаковая и без контроля переполнения,
  * работа с типами символов: `Chr`, `Explode`, `Numb`, `Ord`, `Symb`,
    `Type` — функция `Explode` возвращает имя для заданной функции,
    функция `Numb` не проверяет переполнение,
  * ввод-вывод: `Card`, `Get`, `Open`, `Prout`, `Putout`, `Close`,
    `ExistFile`,
  * операционная система: `Arg`, `GetEnv`, `Exit`, `System`,
  * метафункция `Mu` — просто вызывает функцию по указателю,
  * копилка: `Br`, `Dg`,
  * вспомогательная функция: `First`,
  * функция `ListOfBuiltin`, возвращающая список встроенных функций (она есть
    и в Рефале-5 тоже).

Из соображений минимализма оставлены только те функции, которые реально
используются в компиляторе. Единственное исключение — функция `Card`.
Потому что Рефал без поддержки перфокарт — это ущербный Рефал.

## Установка и использование

Для раскрутки компилятора у Вас должен быть установлен Рефал-5 версии
`PZ Oct 29 2004`, набор библиотек для Рефала-5 [refal-5-framework][r5fw],
а также компилятор языка Си89.

### Установка набора библиотек «refal-5-framework»

Установите библиотеки репозитория [Mazdaywik/refal-5-framework][r5fw]
согласно инструкции в его README.

### Раскрутка на Windows

* Запустите файл `bootstrap.bat`. Cкрипт развёртки создаст файл
  `c-plus-plus.conf.bat` и сообщит о том, что не указан компилятор языка Си.
* Отредактируйте файл `c-plus-plus.conf.bat` (да, я его скопировал у Рефала-5λ
  и забыл переименовать), указав в нём командную строку для запуска компилятора
  (см. инструкции в самом файле).
* Запустите ещё раз `bootstrap.bat` — компилятор должен успешно собраться
  и должны выполниться все автотесты (часть автотестов сообщают об ошибках
  синтаксиса, это так и должно быть).

### Раскрутка на POSIX (Linux, macOS)

Если у Вас установлен компилятор GCC (или Clang на macOS), то достаточно
первого шага:

* Запустите файл `./bootstrap.sh`. В этом случае тоже будет создан файл
  `c-plus-plus.conf.sh`, где по умолчанию будет указан компилятор `gcc`,
  всё должно собраться (некоторые автотесты сообщат о синтаксических ошибках,
  это так и должно быть).

Если у Вас GCC не установлен, или для раскрутки желаете использовать другой
компилятор, то нужно будет отредактировать файл `c-plus-plus.conf.sh`
и запустить `./bootstrap.sh` повторно.

### Установка и конфигурирование

После раскрутки будет создана папка `bin`, в которой будет располагаться
исполнимый файл `refal05c.exe` (или `refal05c`). Его уже можно запускать.
Если его вызвать с именем исходного файла, он скомпилирует его в исходник
на Си. Но, чтобы получать с его помощью получать исполнимые файлы, выполните
следующие действия:

* Добавьте в переменную `PATH` путь к папке `bin` данного дистрибутива.
  Тогда компилятор можно будет запускать из любой папки.
* Установите переменную среды `R05CCOMP` с командной строкой запуска
  компилятора Си. Например, `gcc -Wall -O3 -g`, `cl /EHcs /W3 /wd4996 /O2`,
  `bcc -w`. Когда эта переменная установлена, `refal05c` будет вызывать
  сишный компилятор после генерации исходников.
* Установите переменную среды `R05PATH`, указав в ней через _точку с запятой_
  (Windows) или _двоеточие_ (unix-like) пути к папкам `lib` и `src`
  этого каталога. Например:
  ```
  set R05PATH=C:\Refal-05\lib;C:\Refal-05\src
  ```
  или
  ```
  export R05PATH="~/Refal-05/lib:~/Refal-05/src"
  ```
  В этом случае компилятор сможет находить и подключать библиотеки (рантайм
  и встроенные функции).

**Примечание.** На POSIX-системах (Linux или macOS) в переменную `R05CCOMP`
желательно добавлять `-DR05_POSIX` (например, `gcc -DR05_POSIX`) — в этом
случае функция `System` будет корректно возвращать код возврата. Без данного
флага работать всё равно всё будет, только `System` будет возвращать сырое
значение функции `system` языка Си, которое может отличаться от фактического
кода возврата (см. `man 2 wait` для более подробных сведений).


### Компиляция и запуск программ

Классический пример — Hello, World!:
```
$ENTRY Go {
  = <Prout 'Hello, World!'>
}
```
Сохраните этот текст в файл `hello.ref` и выполните в командной строке команду
```
refal05c hello refal05rts Library
```
Здесь `hello` — это имя нашего исходника (расширение `.ref` здесь можно
не писать), `refal05rts` — библиотека поддержки времени выполнения (на жаргоне —
«рантайм»), содержит функции, которые вызываются из сгенерированного кода,
и `Library` — библиотека со встроенными функциями Рефала (той же `Prout`).

В результате в текущей папке должен появиться файлик `hello.c` — результат
компиляции в Си и исполнимый файл, который, в зависимости от операционной
системы и компилятора Си, может называться `hello.exe`, `a.exe` или `a.out`.
_Примечание._ Некоторые компиляторы языка Си оставляют после себя мусор
из объектных файлов (`.obj`) и других служебных файлов (`.tds`, `.pch`
и т.д.), этот мусор можно (и нужно) удалять. Также можно удалить `hello.c`.

Теперь мы можем запустить программу и увидеть что-то вроде:

```
Hello, World!
```

Как-то так.


## Замечание о дереве коммитов

За основу были взяты ранние коммиты Простого Рефала, но чутка переписаны.

* Все исходники были конвертированы в UTF-8, включая самый нижний коммит.
* Приписана правильная история к метке `003`.
* Из истории удалены коммиты интерпретируемого представления, разработанного
  Игорем Дрогуновым. Я решил, что лучше очистить историю (сделав её более
  «прямой»), чем оставлять те правки, которые потом всё равно удалятся.

Исходную историю и исходные коммиты можно найти в репозитории Рефала-5λ.

## Лицензия

Компилятор распространяется по двухпунктной лицензии BSD с оговоркой
относительно компонентов стандартной библиотеки и рантайма — их можно
распространять в бинарной форме без указания копирайта. При отсутствии данной
оговорки для скомпилированных программ пришлось бы указывать копирайт самого
компилятора, что неразумно.

[r5fw]: https://github.com/Mazdaywik/refal-5-framework
