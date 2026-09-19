# Michi Machines — Plan de desarrollo

## Estado

- [x] Concepto definido: carreras arcade cenitales protagonizadas por gatos.
- [x] Plataformas priorizadas: web, macOS y iPhone/iPad.
- [x] Dirección visual: 2D pixel-art; efectos avanzados después del MVP.
- [~] Fase actual: **Fase 1 — Prototipo de conducción**. La escena carga en Godot 4.7.2; falta probar la sensación de manejo en pantalla y dispositivos reales.
- [~] Fase 2 iniciada: circuito temporal, IA, checkpoints, vueltas y posición ya implementados.

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
- [ ] Crear guía visual temporal y lista de recursos originales.
- [ ] Documentar primera pista y cuatro gatos iniciales.
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
- [~] Ajustar parámetros de manejo hasta que se sienta arcade a 60 FPS.
- [ ] Validar que no hay atascos ni temblores al chocar y recuperarse.

## Fase 2 — Carrera mínima jugable

- [x] Crear checkpoints, vueltas y posiciones en una pista temporal.
- [x] Añadir salida con cuenta regresiva, cronómetro y condición de meta visible.
- [~] Añadir reaparición de seguridad manual desde el último checkpoint (`Backspace`).
- [x] Añadir tres gatos IA con waypoints y conducción normal.
- [x] Añadir HUD temporal de vuelta, posición y velocidad.
- [x] Añadir resultado de meta e inicio rápido de una nueva carrera (`R`).
- [x] Añadir pausa (`Escape`) y pantalla de resultados básica.
- [ ] Validar una carrera completa de tres vueltas contra tres rivales.

## Fase 3 — Vertical slice pixel-art

- [~] Construir infraestructura de superficies y una temática temporal de cocina.
- [~] Añadir utilería de cocina y obstáculos físicos a la primera pista.
- [ ] Diseñar una pista original completa, por ejemplo una cocina gigante.
- [ ] Crear sprites temporales de cuatro gatos, superficies, obstáculos y HUD.
- [ ] Añadir perfiles de gato y dificultades fácil, normal y difícil para IA.
- [ ] Añadir polvo, derrape, choques, música temporal y efectos de sonido.
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

- [ ] Una pista original.
- [ ] Cuatro gatos: uno humano y tres IA.
- [ ] Carrera de tres vueltas con fácil/normal/difícil.
- [ ] Teclado, mando y touch.
- [ ] HUD, pausa, resultados, sonido básico y récord local.
- [ ] Export web y pruebas macOS/iPhone.
