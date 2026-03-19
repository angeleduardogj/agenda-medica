using AgendaMedica.Models;
using AgendaMedica.Services;
using Microsoft.AspNetCore.Mvc;

namespace AgendaMedica.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MedicosController(MedicoService medicoService) : ControllerBase
{
    [HttpGet("obtener")]
    public async Task<ActionResult<IEnumerable<MedicoResponse>>> sp_mst_medicos_obtenertodos()
    {
        var medicos = await medicoService.ObtenerTodosAsync();
        return Ok(medicos);
    }

    [HttpGet("obtener_id/{id}")]
    public async Task<ActionResult<MedicoResponse>> sp_mst_medicos_obtenerporid(int id)
    {
        var medico = await medicoService.ObtenerPorIdAsync(id);
        return Ok(medico);
    }

    [HttpPost("crear")]
    public async Task<ActionResult<MedicoResponse>> sp_mst_medicos_crear(CrearMedicoRequest request)
    {
        var medico = await medicoService.CrearAsync(request);
        return CreatedAtAction(nameof(sp_mst_medicos_obtenerporid), new { id = medico.Id }, medico);
    }

    [HttpPut("actualizar/{id}")]
    public async Task<ActionResult<MedicoResponse>> sp_mst_medicos_actualizar(int id, ActualizarMedicoRequest request)
    {
        var medico = await medicoService.ActualizarAsync(id, request);
        return Ok(medico);
    }

    //(Se implementan borrados logicos)
    [HttpDelete("eliminar/{id}")]
    public async Task<ActionResult> sp_mst_medicos_eliminar(int id)
    {
        await medicoService.EliminarAsync(id);
        return NoContent();
    }

    [HttpGet("horario/{medicoId}")]
    public async Task<ActionResult<IEnumerable<HorarioResponse>>> sp_mst_medicos_obtenerhorarios(int medicoId)
    {
        var horarios = await medicoService.ObtenerHorariosAsync(medicoId);
        return Ok(horarios);
    }

    [HttpPost("horario/crear")]
    public async Task<ActionResult<HorarioResponse>> sp_mst_horarios_crear(CrearHorarioRequest request)
    {
        var nuevoHorario = await medicoService.CrearHorarioAsync(request);
        return Created("", nuevoHorario);
    }

    [HttpPut("horario/actualizar/{horarioId}")]
    public async Task<ActionResult<HorarioResponse>> sp_mst_horarios_actualizar(int horarioId, ActualizarHorarioRequest request)
    {
        var horarioActualizado = await medicoService.ActualizarHorarioAsync(horarioId, request);
        return Ok(horarioActualizado);
    }

    [HttpDelete("horario/eliminar/{horarioId}")]
    public async Task<ActionResult> sp_mst_horarios_eliminar(int horarioId)
    {
        await medicoService.EliminarHorarioAsync(horarioId);
        return NoContent();
    }
}