#!/usr/local/bin/python

import harvestTimer, sys

if __name__ == "__main__":
    # Args
    args = sys.argv[1:]
    try:
        project_name = args[0]
        task_name = args[1]
        if len(args) == 3:
            notes = args[2]
        else:
            notes = None
        # Run it
        harvestTimer.start(project_name, task_name,  notes)
    except:
        print('should have args [project_name] [task_name] [notes]')
        sys.exit(2)
