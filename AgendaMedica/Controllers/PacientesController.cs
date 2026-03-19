using AgendaMedica.Models;
using AgendaMedica.Services;
using Microsoft.AspNetCore.Mvc;

namespace AgendaMedica.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PacientesController(PacienteService pacienteService) : ControllerBase
{
    [HttpGet("obtener")]
    public async Task<ActionResult<IEnumerable<PacienteResponse>>> ObtenerTodos()
    {
        var pacientes = await pacienteService.ObtenerTodosAsync();
        return Ok(pacientes);
    }

    [HttpGet("obtener/{id}")]
    public async Task<ActionResult<PacienteResponse>> ObtenerPorId(int id)
    {
        var paciente = await pacienteService.ObtenerPorIdAsync(id);
        return Ok(paciente);
    }

    [HttpPost("crear")]
    public async Task<ActionResult<PacienteResponse>> Crear(CrearPacienteRequest request)
    {
        var nuevoPaciente = await pacienteService.CrearAsync(request);
        return CreatedAtAction(nameof(ObtenerPorId), new { id = nuevoPaciente.Id }, nuevoPaciente);
    }

    [HttpPut("actualizar/{id}")]
    public async Task<ActionResult<PacienteResponse>> Actualizar(int id, ActualizarPacienteRequest request)
    {
        var pacienteActualizado = await pacienteService.ActualizarAsync(id, request);
        return Ok(pacienteActualizado);
    }

    [HttpDelete("eliminar/{id}")]
    public async Task<ActionResult> Eliminar(int id)
    {
        await pacienteService.EliminarAsync(id);
        return NoContent();
    }
}
