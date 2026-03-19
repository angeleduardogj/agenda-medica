using System.Data;
using AgendaMedica.Middleware;
using AgendaMedica.Models;
using Dapper;
using Microsoft.Data.SqlClient;

namespace AgendaMedica.Services;

public class MedicoService(string connectionString)
{
  
    public async Task<IEnumerable<MedicoResponse>> ObtenerTodosAsync()
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QueryAsync<MedicoResponse>(
            "sp_mst_medicos_obtenertodos",
            commandType: CommandType.StoredProcedure
        );
    }


    public async Task<MedicoResponse> ObtenerPorIdAsync(int id)
    {
        using var conn = new SqlConnection(connectionString);

        var medico = await conn.QueryFirstOrDefaultAsync<MedicoResponse>(
            "sp_mst_medicos_obtenerporid",
            new { id },
            commandType: CommandType.StoredProcedure
        );

        if (medico is null)
            throw new RulesException($"No se encontró el médico con id {id}.", 404);

        return medico;
    }

  
    public async Task<IEnumerable<HorarioResponse>> ObtenerHorariosAsync(int medicoId)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QueryAsync<HorarioResponse>(
            "sp_mst_medicos_obtenerhorarios",
            new { medico_id = medicoId },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<IEnumerable<CitaConsultaResponse>> ObtenerAgendaDiaAsync(int medicoId, DateTime fecha)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QueryAsync<CitaConsultaResponse>(
            "sp_mst_medicos_agenda_dia",
            new
            {
                medico_id = medicoId,
                fecha = fecha.Date
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<IEnumerable<HorarioDisponibleResponse>> ObtenerHorariosDisponiblesAsync(int medicoId, DateTime fecha, int cantidad = 5)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QueryAsync<HorarioDisponibleResponse>(
            "sp_mst_medicos_horarios_disponibles",
            new
            {
                medico_id = medicoId,
                fecha = fecha.Date,
                cantidad
            },
            commandType: CommandType.StoredProcedure
        );
    }


    public async Task<MedicoResponse> CrearAsync(CrearMedicoRequest request)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QuerySingleAsync<MedicoResponse>(
            "sp_mst_medicos_crear",
            new {
                nombre           = request.Nombre.Trim(),
                apellido_paterno = request.ApellidoPaterno.Trim(),
                apellido_materno = request.ApellidoMaterno?.Trim(),
                especialidad     = request.EspecialidadId,
                telefono         = request.Telefono?.Trim(),
                email            = request.Email?.Trim()
            },
            commandType: CommandType.StoredProcedure
        );
    }

   
    public async Task<MedicoResponse> ActualizarAsync(int id, ActualizarMedicoRequest request)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QuerySingleAsync<MedicoResponse>(
            "sp_mst_medicos_actualizar",
            new {
                id,
                nombre           = request.Nombre.Trim(),
                apellido_paterno = request.ApellidoPaterno.Trim(),
                apellido_materno = request.ApellidoMaterno?.Trim(),
                especialidad     = request.EspecialidadId,
                telefono         = request.Telefono?.Trim(),
                email            = request.Email?.Trim()
            },
            commandType: CommandType.StoredProcedure
        );
    }


    public async Task EliminarAsync(int id)
    {
        using var conn = new SqlConnection(connectionString);

        await conn.ExecuteAsync(
            "sp_mst_medicos_eliminar",
            new { id },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<HorarioResponse> CrearHorarioAsync(CrearHorarioRequest request)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QuerySingleAsync<HorarioResponse>(
            "sp_mst_horarios_crear",
            new {
                medico_id   = request.MedicoId,
                dia_semana  = request.DiaSemana,
                hora_inicio = request.HoraInicio,
                hora_fin    = request.HoraFin
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<HorarioResponse> ActualizarHorarioAsync(int horarioId, ActualizarHorarioRequest request)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QuerySingleAsync<HorarioResponse>(
            "sp_mst_horarios_actualizar",
            new {
                id          = horarioId,
                dia_semana  = request.DiaSemana,
                hora_inicio = request.HoraInicio,
                hora_fin    = request.HoraFin
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task EliminarHorarioAsync(int horarioId)
    {
        using var conn = new SqlConnection(connectionString);

        await conn.ExecuteAsync(
            "sp_mst_horarios_eliminar",
            new { id = horarioId },
            commandType: CommandType.StoredProcedure
        );
    }
}
