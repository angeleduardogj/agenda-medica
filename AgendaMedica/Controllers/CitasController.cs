using AgendaMedica.Middleware;
using AgendaMedica.Models;
using AgendaMedica.Services;
using Microsoft.AspNetCore.Mvc;

namespace AgendaMedica.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CitasController(ICitaService citaService) : ControllerBase
{
    [HttpPost("agendar")]
    public async Task<ActionResult<CitaResponse>> Agendar(AgendarCitaRequest request)
    {
        try
        {
            var cita = await citaService.AgendarAsync(request);
            return Created(string.Empty, cita);
        }
        catch (RulesException ex) when (
            ex.StatusCode == 409
            && (
                ex.Message.Contains("ya tiene una cita", StringComparison.OrdinalIgnoreCase)
                || ex.Message.Contains("fuera del horario de consulta", StringComparison.OrdinalIgnoreCase)
                || ex.Message.Contains("no tiene horario de consulta configurado", StringComparison.OrdinalIgnoreCase)
            )
        )
        {
            IEnumerable<HorarioSugeridoResponse> sugerencias = [];
            try
            {
                sugerencias = await citaService.SugerirHorariosAsync(request.MedicoId, request.Fecha, request.HoraInicio, 3);
            }
            catch (RulesException)
            {
            }

            return Conflict(new
            {
                status = 409,
                error = ex.Message,
                sugerencias
            });
        }
    }

    [HttpPut("cancelar/{citaId}")]
    public async Task<ActionResult<CitaResponse>> Cancelar(int citaId, CancelarCitaRequest request)
    {
        var cita = await citaService.CancelarAsync(citaId, request);
        return Ok(cita);
    }

    [HttpGet("consultar")]
    public async Task<ActionResult<IEnumerable<CitaConsultaResponse>>> Consultar(
        [FromQuery] int? medicoId,
        [FromQuery] int? pacienteId,
        [FromQuery] DateTime? fechaDesde,
        [FromQuery] DateTime? fechaHasta,
        [FromQuery] string? estado
    )
    {
        var citas = await citaService.ConsultarAsync(medicoId, pacienteId, fechaDesde, fechaHasta, estado);
        return Ok(citas);
    }

    [HttpGet("sugerencias")]
    public async Task<ActionResult<IEnumerable<HorarioSugeridoResponse>>> Sugerencias(
        [FromQuery] int medicoId,
        [FromQuery] DateTime fecha,
        [FromQuery] TimeSpan horaInicioDeseada,
        [FromQuery] int cantidad = 3
    )
    {
        var sugerencias = await citaService.SugerirHorariosAsync(medicoId, fecha, horaInicioDeseada, cantidad);
        return Ok(sugerencias);
    }
}
