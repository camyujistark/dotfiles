#!/usr/local/bin/python

import harvestTimer, sys

if __name__ == "__main__":
    # Args
    args = sys.argv[1:]
    try:
        project_name = args[0]
        task_name = args[1]
        notes = args[2]
        # Run it
        harvestTimer.stop(project_name, task_name,  notes)
    except:
        print('should have args [project_name] [task_name] [notes]')
        sys.exit(2)
