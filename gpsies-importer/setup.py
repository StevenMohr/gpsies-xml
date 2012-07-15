from setuptools import setup, find_packages

setup(name='GPSies Importer',
      version='1.0',
      description='Importer to query GPSies.org',
      author='Steven Mohr',
      url="https://github.com/StevenMohr/gpsies-xml",
      author_email='steven@stevenmohr.de',
      packages=find_packages() ,
      entry_points = {
        'console_scripts': [
            'gpsies-import = gpsies_importer.start:main',
        ]
      },
      install_requires=["lxml>=2.0"],
      package_data = {
        '': ['*.xsd', '*.xsl', '*.kml'] },
      test_suite = "gpsies_importer.tests.test_all"
     )
