# Seguridad

Clarity es un prototipo académico. No conectes datos reales antes de verificar las reglas de Firestore y Storage y los flujos de autorización.

- Los filtros de la interfaz y el campo `role` en Flutter no son una barrera de autorización.
- Un cliente no debe poder asignarse privilegios ni leer documentos de otros usuarios. Impón estas restricciones en el servicio y pruébalas con emuladores.
- No versiones cuentas de servicio, claves privadas, credenciales de firma de aplicaciones, bases exportadas ni información de usuarios.
- Usa un proyecto Firebase independiente para demostraciones y correos reservados de ejemplo.
- Las claves de API para servicios Firebase no sustituyen las reglas de acceso. Revisa [la lista oficial de seguridad](https://firebase.google.com/support/guides/security-checklist) y aplica las restricciones que correspondan.
- El historial revisado no mostró hallazgos de secretos con Gitleaks. Esto no certifica el servicio Firebase, sus permisos ni la ausencia de todos los riesgos.

No informes datos sensibles en issues públicos. Contacta al autor a través de su perfil para acordar un canal privado.
