from common import ScriptRunner
from java.util import HashMap
from org.python.core import PyDictionary
from org.python.core import PySystemState
from org.python.util import PythonInterpreter

#set = ScriptRunner.methods.keySet()
#for item in set:
#	print item
#	print ScriptRunner.methods.get(item)


path = '/Users/miura/Desktop/test.py'

#ScriptRunner.run(path, HashMap())

pystate = PySystemState()
pystate.setClassLoader(IJ.getClassLoader())
pi = PythonInterpreter(PyDictionary(), pystate)
pi.execfile(path);