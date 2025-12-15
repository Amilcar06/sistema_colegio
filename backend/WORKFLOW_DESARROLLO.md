# Workflow de Desarrollo Local

Esta guía te ayudará a trabajar en el proyecto desde tu máquina ("Localmente") conectándote a la base de datos Dockerizada.

## 1. Prerrequisitos
- **Java 21** (JDK instalado).
- **Maven** (o usar `./mvnw`).
- **Docker** y **Docker Compose** (solo para la Base de Datos).

## 2. Levantar la Base de Datos
El proyecto está configurado para usar PostgreSQL en Docker para evitar instalaciones locales complejas.

1.  Asegúrate de que el puerto **5434** esté libre (usamos este para evitar conflictos con otros Postgres locales).
2.  Ejecuta:
    ```bash
    docker-compose up -d unidadeducativa_db
    ```
    *Esto levantará solo la BD. Si ya tienes el contenedor corriendo, no necesitas hacer nada.*

## 3. Ejecutar la Aplicación (Backend)
Tienes dos formas de correr el backend:

### Opción A: Desde tu IDE (IntelliJ / VS Code) - **Recomendado para programar**
1.  Abre el proyecto en tu IDE.
2.  Busca la clase principal: `com.unidadeducativa.UnidadEducativaApplication`.
3.  Ejecuta **Run** o **Debug**.
    *   *Nota*: Asegúrate de que tu IDE tome la configuración de `application.properties`. Si falla la conexión a BD, verifica que apunte a `localhost:5434`.

### Opción B: Desde Terminal (Como en producción)
1.  Compila el proyecto (esto también verifica errores de sintaxis):
    ```bash
    ./mvnw clean package -DskipTests
    ```
2.  Corre el JAR generado:
    ```bash
    java -jar target/backend-0.0.1-SNAPSHOT.jar \
      --spring.datasource.url=jdbc:postgresql://localhost:5434/unidad_educativa4 \
      --spring.datasource.username=postgres \
      --spring.datasource.password=123456
    ```

## 4. Verificar Errores
Si ves errores en el IDE (subrayado rojo) pero `mvn clean compile` funciona:
1.  Ejecuta en terminal: `mvn clean compile`.
2.  Si termina con `BUILD SUCCESS`, **ignora al IDE**.
3.  Para arreglar el IDE:
    - **IntelliJ**: `File > Invalidate Caches / Restart`.
    - **VS Code**: `Java: Clean Java Language Server Workspace`.

## 5. Swagger API
Una vez corriendo, puedes probar los endpoints sin frontend:
- URL: [http://localhost:8080/swagger-ui/index.html](http://localhost:8080/swagger-ui/index.html)

## 6. Comandos Utiles
Stop BD:
```bash
docker-compose stop
```
Limpiar todo (Borrar BD y empezar de cero):
```bash
docker-compose down -v
```
