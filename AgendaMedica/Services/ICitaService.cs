using AgendaMedica.Models;

namespace AgendaMedica.Services;

public interface ICitaService
{
    Task<CitaResponse> AgendarAsync(AgendarCitaRequest request);
    Task<CitaResponse> CancelarAsync(int citaId, CancelarCitaRequest request);
    Task<IEnumerable<CitaConsultaResponse>> ConsultarAsync(int? medicoId, int? pacienteId, DateTime? fechaDesde, DateTime? fechaHasta, string? estado);
    Task<IEnumerable<HorarioSugeridoResponse>> SugerirHorariosAsync(int medicoId, DateTime fecha, TimeSpan horaInicioDeseada, int cantidad = 3);
}
