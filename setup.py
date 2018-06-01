from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    name="sicl",
    ext_modules=cythonize([Extension("sicl",["sicl.pyx"],libraries=["sicl"])])
)
