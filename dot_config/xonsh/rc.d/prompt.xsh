#! /usr/bin/env xonsh

"""Prompt formatter for current jobs"""

import contextlib
import typing as tp

from xonsh.prompt.base import PromptField

# Extracted from vanilla xonsh
class CurrentJobField(PromptField):
    _current_cmds: tp.Optional[list] = None

    def update(self, ctx):
        if self._current_cmds is not None:
            cmd = self._current_cmds[-1]
            s = cmd[0]
            if s == "sudo" and len(cmd) > 1:
                s = cmd[1]
            self.value = s
        else:
            self.value = None
	# This is custom, because else empty shell shows cat running all the time
        if self.value == "cat" and len(cmd) == 1:
            self.value = None

    @contextlib.contextmanager
    def update_current_cmds(self, cmds):
        """Context manager that updates the information used to update the job name"""
        old_cmds = self._current_cmds
        try:
            self._current_cmds = cmds
            yield
        finally:
            self._current_cmds = old_cmds

$PROMPT_FIELDS["current_job"] = CurrentJobField()
