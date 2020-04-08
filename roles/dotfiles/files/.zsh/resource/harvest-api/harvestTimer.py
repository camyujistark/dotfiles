#!/usr/local/bin/python

import harvest
import creds

client = harvest.Harvest(creds.url, creds.user, creds.password)
projects = creds.projects

def task_init(project_name, task_name, notes):
    taskNotes = notes if notes else projects[project_name]["task"][task_name]["notes"]
    data = {
        "notes": taskNotes,
        "project_id": projects[project_name]['project_id'],
        "task_id": projects[project_name]['task'][task_name]["task_id"],
    }
    client.add(data)

def has_timer_started(entry):
    return 'timer_started_at' in entry.keys()

def timer(start, project_name, task_name, notes):
    task = projects[project_name]['task'][task_name]
    entries = client.today_user(creds.user_id)
    day_entries = entries['day_entries']
    entry_exists = False
    task_notes = notes if notes else task['notes']
    for entry in day_entries:
        if entry['task_id'] == task['task_id'] and entry['notes'] == task_notes:
            if(start == 'start'):
                client.toggle_timer(entry['id']) if has_timer_started(entry) == 0 else 0
            elif(start == 'stop'):
                client.toggle_timer(entry['id']) if has_timer_started(entry) == 1 else 0
            entry_exists = True
            break
    if not entry_exists:
        task_init(project_name, task_name, task_notes)

def start(projects, task_name, notes):
    timer('start', projects, task_name, notes)

def stop(projects, task_name, notes):
    timer('stop', projects, task_name, notes)
