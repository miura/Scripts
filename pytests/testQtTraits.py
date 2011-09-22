# -*- coding: utf-8 -*-
"""
Created on Wed Jul 27 11:54:14 2011

@author: -
"""

from enthought.traits.api import HasTraits, Int

class Demo(HasTraits):
    i = Int()

d = Demo()
d.configure_traits()
