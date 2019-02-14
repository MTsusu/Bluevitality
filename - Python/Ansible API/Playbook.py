# -*- coding: utf-8 -*-

import os, sys
import json
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.playbook import Playbook

from ansible import constants as C
from ansible.utils.ssh_functions import check_for_controlpersist
from ansible.executor.playbook_executor import PlaybookExecutor
from ansible.plugins.callback import CallbackBase
from rest_framework import serializers

# 修复__main__环境下的引入问题
import repackage

repackage.up()
from v2_4.base import AnsibleBase


class results_callback(CallbackBase):
    CALLBACK_VERSION = 2.0

    def __init__(self, *args, **kwargs):
        super(results_callback, self).__init__(*args, **kwargs)
        self.task_ok = {}
        self.task_skipped = {}
        self.task_failed = {}
        self.task_status = {}
        self.task_unreachable = {}
        self.task_changed = {}

    def v2_runner_on_ok(self, result, *args, **kwargs):
        self.task_ok[result._host.get_name()] = result

    def v2_runner_on_failed(self, result, *args, **kwargs):
        self.task_failed[result._host.get_name()] = result

    def v2_runner_on_unreachable(self, result):
        self.task_unreachable[result._host.get_name()] = result

    def v2_runner_on_skipped(self, result):
        self.task_ok[result._host.get_name()] = result

    def v2_runner_on_changed(self, result):
        self.task_changed[result._host.get_name()] = result

    def v2_playbook_on_stats(self, stats):
        hosts = sorted(stats.processed.keys())
        for h in hosts:
            t = stats.summarize(h)
            self.task_status[h] = {
                "ok": t['ok'],
                "changed": t['changed'],
                "unreachable": t['unreachable'],
                "skipped": t['skipped'],
                "failed": t['failures']
            }

class Playbook(AnsibleBase):
    def get_playbook_result(self):
        self.results_raw = {'skipped': {}, 'failed': {}, 'ok': {}, "status": {}, 'unreachable': {}, "changed": {}}

        for host, result in self.callback.task_ok.items():
            self.results_raw['ok'][host] = result

        for host, result in self.callback.task_failed.items():
            self.results_raw['failed'][host] = result

        for host, result in self.callback.task_status.items():
            self.results_raw['status'][host] = result

        for host, result in self.callback.task_changed.items():
            self.results_raw['changed'][host] = result

        for host, result in self.callback.task_skipped.items():
            self.results_raw['skipped'][host] = result

        for host, result in self.callback.task_unreachable.items():
            self.results_raw['unreachable'][host] = result
        return self.results_raw

    def result_succ(self):
        result = self.get_playbook_result()
        status = result['status']
        for state in status:
            if status[state]['unreachable'] > 0 :
                return False
            if status[state]['failed'] > 0 :
                return False
        return True

    def run(self):
        self.callback = results_callback()

        try:
            curr_dir = os.path.split(os.path.realpath(__file__))[0]
            _ymlfile = curr_dir + '/playbooks/' + self.yamlfile
            self.loader.set_basedir(curr_dir + '/playbooks')

            pb = PlaybookExecutor(playbooks=[_ymlfile],
                                  inventory=self.inventory,
                                  variable_manager=self.variable_manager,
                                  loader=self.loader,
                                  options=self.options,
                                  passwords=None)
            pb._tqm._stdout_callback = self.callback

            res = pb.run()
        except Exception as e:
            print(e)
            return False


if __name__ == '__main__':

    #    resource =[
    #        {'hostname': '127.0.0.1', 'username': 'macroon', 'password': 'Summer', },
    #        {'hostname': '192.168.100.4', 'username': 'zyzx', 'password': 'Uo_b_mG3', },
    #    ]

    hosts = [
        {'ip': '127.0.0.1', },
        #{'ip': '192.168.100.4'},
    ]
    group = {'ssh_user': 'zyzx', 'ssh_pass': 'Uo_b_mG3'}
    group = {'ssh_user': 'rhkf', 'ssh_pass': 'Summer'}
    tasks = None
    yamlfile = 'install_cronolog.yml'

    try:
        pb = Playbook(hosts, group, tasks, yamlfile)
        pb.run()
        result = pb.get_result()
        print(json.dumps(pb.get_result()))
        print(pb.result_succ())

    except Exception  as error:
        pass
