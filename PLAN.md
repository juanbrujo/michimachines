# Michi Machines — Plan de desarrollo

## Estado

- [x] Concepto definido: carreras arcade cenitales protagonizadas por gatos.
- [x] Plataformas priorizadas: web, macOS y iPhone/iPad.
- [x] Dirección visual: 2D pixel-art; efectos avanzados después del MVP.
- [~] Fase actual: **Fase 3 — Vertical slice pixel-art**. La carrera completa ya funciona con selección de michi, rivales, poderes, HUD y arte inicial; quedan pulido, audio, pruebas móviles y exportación.

## Visión

**Michi Machines** será una carrera arcade cenital de gatos, rápida y legible, en mundos domésticos gigantes: cocinas, escritorios, jardines y talleres. Conservaremos el ritmo y la sensación de escala de los clásicos de miniaturas, pero con nombre, gatos, pistas, arte, interfaz, audio y narrativa originales.

## Base técnica

| Área | Decisión |
| --- | --- |
| Motor | Godot 4.x con GDScript |
| Destinos | Web, macOS, iPhone/iPad |
| Resolución | 640×360, escalado entero y filtro nearest |
| Cámara | Cenital 2D pixel-art |
| Gatos | `CharacterBody2D` con control arcade |
| Escenario | `TileMapLayer` y cuerpos estáticos/polígonos de colisión |
| Colisiones | Física nativa para escenario; respuesta arcade para gato vs. gato |
| Input | Acciones abstractas para teclado, mando y touch |

## Fase 0 — Preproducción y base técnica

- [x] Crear la estructura del proyecto Godot.
- [x] Configurar viewport 640×360, escalado pixel-perfect y física a 60 FPS.
- [x] Definir acciones abstractas de teclado y adaptador touch temporal.
- [ ] Configurar plantillas y presets de exportación para web, macOS e iOS.
- [x] Crear guía visual temporal y lista de recursos originales (`README.md` y `prompts.md`).
- [x] Documentar primera pista y cuatro gatos iniciales.
- [x] Personalizar corredores con los gatos reales: Ñau, Cajú, Romeo y Osama, con estadísticas propias.
- [ ] Confirmar que el proyecto abre y exporta en navegador/macOS.

## Fase 1 — Prototipo de conducción

**Objetivo:** un gato divertido de controlar antes de producir contenido final.

- [x] Implementar acelerar, frenar/reversa, giro según velocidad, fricción y derrape.
- [x] Crear colisionador justo para el gato y muros/obstáculo estáticos.
- [x] Añadir arena de pruebas sin arte final.
- [x] Añadir controles de teclado y cuatro botones táctiles temporales.
- [x] Validar carga y ejecución automática de la escena en Godot 4.7.2.
- [x] Probar el control con teclado en un dispositivo real.
- [x] Añadir soporte de mando: stick izquierdo para girar, A/RB para acelerar, B/LB para frenar.
- [~] Probar mando y touch en dispositivos reales.
- [x] Ajustar parámetros de manejo hasta que se sienta arcade a 60 FPS; velocidad, respuesta, curvas y recuperación reequilibradas tras pruebas manuales.
- [ ] Validar que no hay atascos ni temblores al chocar y recuperarse.

## Fase 2 — Carrera mínima jugable

- [x] Crear checkpoints, vueltas y posiciones en una pista temporal.
- [x] Añadir salida con cuenta regresiva, cronómetro y condición de meta visible.
- [x] Añadir reaparición de seguridad manual desde el último checkpoint (`Backspace`).
- [x] Añadir tres gatos IA con waypoints y conducción normal.
- [x] Añadir HUD temporal de vuelta, posición y velocidad.
- [x] Añadir resultado de meta e inicio rápido de una nueva carrera (`R`).
- [x] Añadir pausa (`Escape`) y pantalla de resultados básica.
- [x] Terminar la carrera cuando cualquier michi gana y mostrar resultado/podio.
- [x] Guardar récord local de vuelta completa por michi.
- [x] Añadir menú temporal con acceso a carrera rápida y resumen de controles.
- [x] Añadir selector de ritmo tranquilo, normal y rápido para los rivales.
- [x] Añadir selección de michi con estadísticas de velocidad, curvas e impacto: Ñau, Cajú, Romeo y Osama.
- [x] Validar una carrera completa de tres vueltas contra tres rivales en escritorio.

## Fase 3 — Vertical slice pixel-art

- [x] Construir infraestructura de superficies y una temática temporal de cocina.
- [x] Añadir utilería de cocina y obstáculos físicos a la primera pista.
- [~] Integrar arte de cocina, obstáculos, poderes y HUD de carrera entregado; faltan tiles modulares, podio y ajuste visual fino.
- [x] Añadir cámara de persecución suave que concentra la vista en Michi y la ruta cercana.
- [x] Añadir pickups automáticos: rapidez temporal, terremoto contra rivales y aceite resbaladizo; disponibles para los cuatro michis.
- [x] Garantizar un pickup visible al inicio de carrera y evitar que se consuma durante la cuenta regresiva.
- [ ] Diseñar una pista original completa, por ejemplo una cocina gigante.
- [x] Crear sprites temporales de cuatro gatos, superficies, obstáculos y HUD; los gatos, la utilería y el HUD principal ya usan arte entregado.
- [~] Mejorar IA: anticipación de curvas, frenado, recuperación y carril de adelantamiento implementados; faltan pruebas manuales por dificultad.
- [~] Añadir polvo, derrape, choques, música temporal y efectos de sonido; ya hay respuesta y destellos de impacto, faltan efectos visuales de derrape, música y sonido.
- [ ] Validar una partida completa en escritorio y Safari de iPhone.

## Fase 4 — Móvil y distribución

- [ ] Pulir controles touch, zonas seguras, botones y pausa por pérdida de foco.
- [ ] Probar resoluciones de iPhone/iPad horizontal.
- [ ] Optimizar rendimiento y tamaño de descarga web.
- [ ] Generar builds web/macOS y proyecto iOS para Xcode.
- [ ] Preparar iconos, pantalla de carga, privacidad y metadatos.

## Fase 5 — Contenido y pulido

- [ ] Añadir pistas, superficies, obstáculos, gatos desbloqueables y récords.
- [ ] Mejorar IA, accesibilidad, controles y opciones de sonido.
- [ ] Evaluar multijugador local; dejar online para una fase posterior.
- [ ] Añadir luces, sombras, huellas y efectos mejorados si mantienen la legibilidad.

## Alcance del MVP

- [~] Una pista original de cocina: recorrido jugable construido; falta convertirlo en pista final con tiles modulares.
- [x] Cuatro gatos: uno humano y tres IA.
- [x] Carrera de tres vueltas con fácil/normal/difícil.
- [x] Teclado, mando y touch implementados.
- [x] HUD, pausa, resultados y récord local.
- [ ] Export web y pruebas macOS/iPhone.
