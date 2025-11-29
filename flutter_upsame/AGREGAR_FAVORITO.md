# Agregar Botón de Favorito al Perfil Público

## Instrucción Rápida

He creado un widget reutilizable `FavoriteButton` que puedes agregar fácilmente al perfil público.

### Paso 1: Agregar el Import

En `lib/screens/public_profile_page.dart`, línea 7, agrega:

```dart
import '../widgets/favorite_button.dart';
```

### Paso 2: Agregar el Botón al AppBar

Busca el `SliverAppBar` (alrededor de línea 358-392) y agrega `actions` con el botón de favorito:

Busca esta sección:
```dart
SliverAppBar(
  expandedHeight: 280,
  backgroundColor: _primaryGreen,
  foregroundColor: Colors.white,
  elevation: 0,
  pinned: true,
```

Y agrega DENTRO del SliverAppBar (antes de `flexibleSpace`):

```dart
actions: [
  FavoriteButton(userId: widget.userId),
  const SizedBox(width: 8),
],
```

El resultado debe verse así:

```dart
SliverAppBar(
  expandedHeight: 280,
  backgroundColor: _primaryGreen,
  foregroundColor: Colors.white,
  elevation: 0,
  pinned: true,
  actions: [
    FavoriteButton(userId: widget.userId),
    const SizedBox(width: 8),
  ],
  flexibleSpace: FlexibleSpaceBar(
    ...
  ),
),
```

## ¡Listo!

Ahora cuando visites un perfil público, verás un corazoncito en la esquina superior derecha:
- Corazón vacío = No es favorito (presiona para agregar)
- Corazón rojo lleno = Es favorito (presiona para quitar)

El botón maneja automáticamente:
- Estado de carga
- Llamadas al API
- Mensajes de confirmación
- Manejo de errores
