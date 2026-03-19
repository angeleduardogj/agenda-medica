using System.Data;
using AgendaMedica.Middleware;
using AgendaMedica.Models;
using Dapper;
using Microsoft.Data.SqlClient;

namespace AgendaMedica.Services;

public class PacienteService(string connectionString)
{
    public async Task<IEnumerable<PacienteResponse>> ObtenerTodosAsync()
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QueryAsync<PacienteResponse>(
            "sp_mst_pacientes_obtenertodos",
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<PacienteResponse> ObtenerPorIdAsync(int id)
    {
        using var conn = new SqlConnection(connectionString);

        var paciente = await conn.QueryFirstOrDefaultAsync<PacienteResponse>(
            "sp_mst_pacientes_obtenerporid",
            new { id },
            commandType: CommandType.StoredProcedure
        );

        if (paciente is null)
            throw new RulesException($"No se encontró el paciente con id {id}.", 404);

        return paciente;
    }

    public async Task<PacienteResponse> CrearAsync(CrearPacienteRequest request)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QuerySingleAsync<PacienteResponse>(
            "sp_mst_pacientes_crear",
            new {
                nombre           = request.Nombre.Trim(),
                apellido_paterno = request.ApellidoPaterno.Trim(),
                apellido_materno = request.ApellidoMaterno?.Trim(),
                fecha_nacimiento = request.FechaNacimiento,
                telefono         = request.Telefono?.Trim(),
                email            = request.Email?.Trim()
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<PacienteResponse> ActualizarAsync(int id, ActualizarPacienteRequest request)
    {
        using var conn = new SqlConnection(connectionString);

        return await conn.QuerySingleAsync<PacienteResponse>(
            "sp_mst_pacientes_actualizar",
            new {
                id,
                nombre           = request.Nombre.Trim(),
                apellido_paterno = request.ApellidoPaterno.Trim(),
                apellido_materno = request.ApellidoMaterno?.Trim(),
                fecha_nacimiento = request.FechaNacimiento,
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
            "sp_mst_pacientes_eliminar",
            new { id },
            commandType: CommandType.StoredProcedure
        );
    }
}
