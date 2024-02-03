CONDA - PY


Sprint1: Creación del proyecto
Usuario1: Crear el proyecto en GitHub
Usuario2: Clonar e implementar las primeras librerías
Usuario3: Codigo para leer el dataset



readme.md: Portada del proyecto como ejecutar el proyecto
Que comandos necesitas
Persona que creo elm proyecto/empresa
Usuarios


CREAR ENTORNO
#Crear entorno en conda:
> conda create -n entorno1
> condo create —name entorno 1

#instalar python 3.9 en el entorno
> conda create -n entorno1 Python=3.9

#Activar el entorno1
> conda activate entorno1

#Salir del entorno1
> conda deactivate entorno1

#Lista todos los entornos que se tiene
> conda env list
> conda info —envs

#Eliminar entorno
conda env remove --name mi_entorno

#Paquetes del entorno1
> conda list

#instalar pip en entorno
> conda install pip

#instalar paquetes con pip
> pip install pgmpy

#Creando entorno2
> conda create —name entorno2 Python=3.10

#Ingresando al entorno2
> conda activate entorno2

#instalar libraries en entorno2
> conda install bumpy matplotlib pandas

#Exportar libraries de un entorno
> conda env export > entorno2.yml

GIT
#verificar los cambios realizados en las ramas
> git log

#Ir a la rama principal
> git checkout main

#Unir los cambios de la rama editada a la rama main (estando en main)
> git merge Pedro

Fixes #1: Prueba de resolución (Agregar esto en el commit con ese nombre)

1:19:21


#Crear entornopython -m ipykernel install --user --name entornoDP03 --display-name "Python 3.11 (entornoDP03)"




