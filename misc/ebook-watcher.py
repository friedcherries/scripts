#!/usr/bin/env python3
import logging
import pathlib
import shutil
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

logging.basicConfig(filename="/var/log/ebook-watcher.log",
                    encoding='utf-8', level=logging.INFO)

TARGET_DIRECTORY = "/usr/local/containers/calibre/auto-import/"
DIRECTORY_TO_WATCH = "/usr/local/containers/nzbget/downloads/completed/Ebooks/"


class Watcher:
    DIRECTORY_TO_WATCH = ""

    def __init__(self):
        self.DIRECTORY_TO_WATCH = DIRECTORY_TO_WATCH
        self.observer = Observer()

    def run(self):
        event_handler = Handler()
        self.observer.schedule(
            event_handler, self.DIRECTORY_TO_WATCH, recursive=True)
        self.observer.start()
        try:
            while True:
                time.sleep(5)
        except Exception as e:
            self.observer.stop()
            logging.error("Error: {}".format(e))

        self.observer.join()


class Handler(FileSystemEventHandler):

    @ staticmethod
    def on_any_event(event):
        if event.event_type in ['created', 'closed', 'moved']:
            if event.event_type == 'moved':
                the_file = pathlib.Path(event.dest_path)
            else:
                the_file = pathlib.Path(event.src_path)

            if the_file.exists() and the_file.is_file() and the_file.name.lower().endswith('.epub') and not str(the_file.parent).endswith('_unpack'):
                base_file = the_file.name
                new_file = pathlib.Path(f"{TARGET_DIRECTORY}{base_file}")

                if not new_file.exists():
                    # Move the file to the target
                    logging.info("Moving {}".format(the_file))
                                        shutil.move(str(the_file), str(new_file))
        else:
            logging.info(event)

if __name__ == '__main__':
    w = Watcher()
    w.run()
