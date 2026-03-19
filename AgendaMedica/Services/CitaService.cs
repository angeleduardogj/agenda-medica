using System.Data;
using AgendaMedica.Models;
using Dapper;
using Microsoft.Data.SqlClient;

namespace AgendaMedica.Services;

public class CitaService(string connectionString)
{
    public async Task<CitaResponse> AgendarAsync(AgendarCitaRequest request)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QuerySingleAsync<CitaResponse>(
            "sp_trx_citas_agendar",
            new
            {
                medico_id = request.MedicoId,
                paciente_id = request.PacienteId,
                fecha = request.Fecha.Date,
                hora_inicio = request.HoraInicio,
                motivo = request.Motivo.Trim()
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<CitaResponse> CancelarAsync(int citaId, CancelarCitaRequest request)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QuerySingleAsync<CitaResponse>(
            "sp_trx_citas_cancelar",
            new
            {
                cita_id = citaId,
                motivo_cancelacion = request.MotivoCancelacion.Trim()
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<IEnumerable<CitaConsultaResponse>> ConsultarAsync(int? medicoId, int? pacienteId, DateTime? fechaDesde, DateTime? fechaHasta, string? estado)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QueryAsync<CitaConsultaResponse>(
            "sp_trx_citas_consultar",
            new
            {
                medico_id = medicoId,
                paciente_id = pacienteId,
                fecha_desde = fechaDesde,
                fecha_hasta = fechaHasta,
                estado = string.IsNullOrWhiteSpace(estado) ? null : estado.Trim()
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<IEnumerable<HorarioSugeridoResponse>> SugerirHorariosAsync(int medicoId, DateTime fecha, TimeSpan horaInicioDeseada, int cantidad = 3)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QueryAsync<HorarioSugeridoResponse>(
            "sp_trx_citas_sugerir_horarios",
            new
            {
                medico_id = medicoId,
                fecha = fecha.Date,
                hora_inicio_deseada = horaInicioDeseada,
                cantidad
            },
            commandType: CommandType.StoredProcedure
        );
    }
}
